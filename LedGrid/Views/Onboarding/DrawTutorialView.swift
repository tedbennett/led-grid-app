//
//  DrawTutorialView.swift
//  LedGrid
//
//  Created by Ted Bennett on 12/11/2022.
//

import SwiftUI
import AlertToast

struct DrawTutorialView: View {
    
    enum Step {
        case draw
        case changeColour
        case copyColour
        case fillColour
    }
    
    
    @State private var step: Step = .draw
    @State private var stepComplete = false
    @State private var finishedSteps = false
    var onComplete: () -> Void
    @StateObject var colourViewModel = DrawColourViewModel()
    @StateObject var viewModel = {
        var viewModel = DrawViewModel()
        viewModel.setCurrentGrids([DEFAULT_GRID])
        return viewModel
    }()
    @State private var translation = CGSize.zero
    @State private var showColorChangeToast = false
    
    func completeStep(nextStep: Step) {
        guard nextStep != step && !stepComplete else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        Task {
            await MainActor.run {
                withAnimation {
                    stepComplete = true
                }
            }
            try? await Task.sleep(nanoseconds: 1 * 1_500_000_000)
            await MainActor.run {
                withAnimation {
                    step = nextStep
                    stepComplete = false
                }
                
            }
        }
    }
    
    var doneButton: some View {
        Button {
            Utility.currentGrids = [viewModel.currentGrid]
            onComplete()
        } label: {
            let text: String = {
                switch step {
                    case .draw: return "Tip 1/4"
                    case .changeColour: return "Tip 2/4"
                    case .copyColour: return "Tip 3/4"
                   case .fillColour: return stepComplete ? "Done" : "Tip 4/4"
                }
            }()
            HStack {
                Text(text)
                if finishedSteps {
                    Image(systemName: "chevron.right")
                }
            }
        }.buttonStyle(LargeButton())
        .disabled(!finishedSteps)
    }
    
    var body: some View {
        VStack {
            VStack {
                Image(systemName: "pencil.circle").font(.largeTitle)
                Text("Drawing Tips")
                    .font(.system(size: 30, design: .rounded).weight(.bold))
            }
            .fadeInWithDelay(0.3)
            .padding(20)
            
            VStack {
                DrawGridView(colorViewModel: colourViewModel) {
                    if step == .draw {
                        completeStep(nextStep: .changeColour)
                    }
                } onDrag: {
                    if step == .draw {
                        completeStep(nextStep: .changeColour)
                    }
                } onLongPress: {
                    if step == .copyColour {
                        completeStep(nextStep: .fillColour)
                    }
                    showColorChangeToast = true
                }
                    .environmentObject(viewModel)
                HStack {
                    Spacer()
                    ColorPickerView(
                        viewModel: colourViewModel,
                        translation: $translation,
                        showSliders: $colourViewModel.showSliders
                    ) { drag in
                        withAnimation {
                            translation = drag
                        }
                        if colourViewModel.showSliders {
                            withAnimation {
                                colourViewModel.showSliders = false
                            }
                        }
                    } onDragEnd: { location in
                        if let coordinates = viewModel.findGridCoordinates(at: location) {
                            viewModel.fillGrid(at: coordinates, color: colourViewModel.currentColor)
                            translation = CGSize.zero
                            if step == .fillColour && !stepComplete {
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                withAnimation {
                                    stepComplete = true
                                }
                                withAnimation(.default.delay(1)) {
                                    finishedSteps = true
                                }
                            }
                        } else {
                            withAnimation {
                                translation = CGSize.zero
                            }
                        }
                        
                    }
                    .onChange(of: colourViewModel.currentColor) { _ in
                        if step == .changeColour {
                            completeStep(nextStep: .copyColour)
                        }
                    }
                }
            }.padding()
            .fadeInWithDelay(0.6)
            VStack(alignment: .leading, spacing: 10) {
                switch step {
                case .draw:
                    DrawTutorialStepView(isComplete: stepComplete, text: "Tap or drag on any square on the grid to colour it")
                        .transition(.asymmetric(insertion: .opacity, removal: .slide).combined(with: .opacity))
                case .changeColour:
                    DrawTutorialStepView(isComplete: stepComplete, text: "Tap the circle at the bottom to change your selected colour")
                        .transition(.slide.combined(with: .opacity))
                case .copyColour:
                    DrawTutorialStepView(isComplete: stepComplete, text: "Long press any square in the grid to copy that colour")
                        .transition(.slide.combined(with: .opacity))
                case .fillColour:
                    DrawTutorialStepView(isComplete: stepComplete, text: "Drag from the circle at the bottom to the grid to fill with the selected colour")
                        .transition(.asymmetric(insertion: .slide, removal: .opacity).combined(with: .opacity))
                        .opacity(finishedSteps ? 0 : 1)
                }
            }.padding(.vertical)
            .fadeInWithDelay(0.9)
            VStack {
                doneButton
                    .padding(.horizontal, 30)
                Button {
                    onComplete()
                } label: {
                    HStack {
                        Text("Skip")
                        Image(systemName: "chevron.right")
                    }.foregroundColor(.gray)
                }.padding(5)
                    .opacity(finishedSteps ? 0 : 1)
            }
            .fadeInWithDelay(0.9)
                
        }
        .toast(isPresenting: $showColorChangeToast, duration: 1.0) {
            AlertToast(displayMode: .hud, type: .complete(.white), title: "Color copied!")
        }
    }
}

struct DrawTutorialView_Previews: PreviewProvider {
    let transition = AnyTransition.slide.combined(with: .opacity)
    
    static var previews: some View {
        DrawTutorialView {
            
        }.padding()
    }
}

struct DrawTutorialStepView: View {
    var isComplete: Bool
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: isComplete ? "checkmark.circle" : "xmark.circle").font(.title3)
                .foregroundColor(isComplete ? .green : .gray)
            Text(text)
                .font(.system(size: 18, design: .rounded).weight(.medium))
        }
    }
}
