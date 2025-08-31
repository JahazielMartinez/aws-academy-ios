
import SwiftUI

struct ServiceCard: View {
    let service: Service
    var isCompact: Bool = false
    
    var body: some View {
        if isCompact {
            compactView
        } else {
            fullView
        }
    }
    
    private var compactView: some View {
        VStack(alignment: .leading, spacing: Theme.paddingS) {
            HStack {
                Image(systemName: service.icon)
                    .font(.title3)
                    .foregroundColor(Theme.awsOrange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(service.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("\(service.estimatedMinutes) min")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
            }
            
            if service.completionPercentage > 0 {
                ProgressView(value: service.completionPercentage / 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: Theme.awsOrange))
            }
        }
        .frame(width: 150)
        .padding(Theme.paddingM)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
    
    private var fullView: some View {
        HStack(spacing: Theme.paddingM) {
            Image(systemName: service.icon)
                .font(.title2)
                .foregroundColor(Theme.awsOrange)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: Theme.paddingXS) {
                Text(service.name)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Text(service.description)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(2)
                
                HStack {
                    Label("\(service.estimatedMinutes) min", systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(Theme.textTertiary)
                    
                    Text("•")
                        .foregroundColor(Theme.textTertiary)
                    
                    Text(service.difficulty.rawValue)
                        .font(.caption2)
                        .foregroundColor(Theme.textTertiary)
                }
            }
            
            Spacer()
            
            if service.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if service.completionPercentage > 0 {
                CircularProgressView(progress: service.completionPercentage / 100)
                    .frame(width: 30, height: 30)
            }
        }
        .padding(Theme.paddingM)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 3)
                .opacity(0.3)
                .foregroundColor(Theme.awsOrange)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .foregroundColor(Theme.awsOrange)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: 8))
                .fontWeight(.medium)
                .foregroundColor(Theme.textPrimary)
        }
    }
}

struct ServiceCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ServiceCard(service: Service(
                name: "EC2",
                fullName: "Elastic Compute Cloud",
                description: "Servidores virtuales en la nube",
                icon: "server.rack",
                difficulty: .basic,
                estimatedMinutes: 20,
                completionPercentage: 65
            ))
            
            ServiceCard(service: Service(
                name: "S3",
                fullName: "Simple Storage Service",
                description: "Almacenamiento de objetos",
                icon: "externaldrive",
                difficulty: .basic,
                estimatedMinutes: 15,
                isCompleted: true
            ), isCompact: true)
        }
        .padding()
    }
}
