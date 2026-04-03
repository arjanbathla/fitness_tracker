import Foundation
import CoreMotion

class StepCounterService: ObservableObject {
    private var pedometer = CMPedometer()

    @Published var steps: Int = 0
    @Published var distance: Double = 0.0 // in km

    func startCounting() {
        // check if step counting is available
        guard CMPedometer.isStepCountingAvailable() else {
            print("step counting not available")
            return
        }

        // query from midnight today
        let midnight = Calendar.current.startOfDay(for: Date())

        pedometer.startUpdates(from: midnight) { [weak self] data, error in
            if let error = error {
                print("pedometer error: \(error)")
                return
            }
            guard let data = data else { return }

            DispatchQueue.main.async {
                self?.steps = data.numberOfSteps.intValue
                if let dist = data.distance {
                    self?.distance = dist.doubleValue / 1000.0
                }
            }
        }
    }

    func stopCounting() {
        pedometer.stopUpdates()
    }
}
