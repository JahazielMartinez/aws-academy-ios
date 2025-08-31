
import Foundation

struct AWSConfiguration {
    // Estas variables se llenarán desde AWS Amplify
    static let region = "us-east-1"
    static let identityPoolId = "" // Se llenará después
    static let userPoolId = "" // Se llenará después
    static let appClientId = "" // Se llenará después
    
    // S3 Configuration
    static let s3BucketName = "awsacademy-content"
    
    // API Configuration
    static let apiEndpoint = "" // Se llenará después
}

