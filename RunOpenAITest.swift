import Foundation
import GlowPlan

print("Starting OpenAI Routine Generation Test...")
OpenAIConfig.setupOpenAI() 
OpenAITest.runAllTests()

// Keep the script running to see test results
RunLoop.main.run(until: Date(timeIntervalSinceNow: 60)) 