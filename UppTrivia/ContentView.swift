//
//  ContentView.swift
//  UppTrivia
//
//  Created by Michael Howard on 2023/01/20.
//

import SwiftUI

struct TriviaQuestion {
    let answer: String?
    let question: String?
    let value: Int?
}

extension TriviaQuestion: Decodable {
    enum CodingKeys: String, CodingKey {
        case answer = "answer"
        case question = "question"
        case value = "value"
    }
}

struct ContentView: View {
    
    @State var questionHeader: String = ""
    @State var question: String = ""
    @State var answerHeader: String = ""
    @State var answer: String = ""
    @State var welcomeMessage: String = "Generates random trivia questions and answers so you can amaze your peers with your extensive knowledge on things they don't teach in school. Go on and hit me!"
    
    @State var showAlert = false
    
    @State var labels: [String : String] = [
            "header" : "Checking Server Availability...",
            "footer" : "UPPTRIVIA"
            
        ]
    
    var body: some View {
        VStack {
            Text(labels["header"]!)
            Spacer()
            logoView
            Spacer()
            textView
            
            Button("Hit Me!!") {
                welcomeMessage = ""
                question = "I'm fetching the things..."
                answer = ""
                fetch {list in
                    questionHeader = "Question:"
                    answerHeader = "Answer:"
                    question = list[0].question ?? "Oops that did not work..."
                    answer = list[0].answer ?? ""
                }
            }
            .frame(width: 150, height: 50)
            .font(.title)
            .foregroundColor(Color.white)
            .background(Color.green)
            .cornerRadius(10)
            
            Spacer()
            
            Text(labels["footer"]!).foregroundColor(.white)
        }.onAppear(perform: initialize)
            .background(
                Image("bg-trivia")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            .alert("Seems like the server went away for a while...", isPresented: $showAlert) {
                Button("I'm dissapointed..", role: .cancel){}
            }
        .padding()
    }
    
    var logoView: some View {
        VStack {
            Image("logo")
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)
//                        .frame(width: 300, height: 200)
        }
    }
    
    var textView: some View {
        VStack {
            Text(welcomeMessage)
            Text(questionHeader).bold()
            Text(question)
            Text(answerHeader).bold()
            Text(answer)
        }
    }
    
    private func initialize() {
        fetch { list in
            if list.isEmpty {
                labels["header"]! = "Error contacting Server (:"
                showAlert = true
            } else {
                labels["header"]! = "Contacting server success!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    labels["header"]! = ""
                }
            }
        }
    }
    
    private func fetch(completionHandler: @escaping ([TriviaQuestion]) -> Void) {
        let url = composeUrl(url: "https://jservice.io/api/random")

        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
          if let error = error {
              print("Error with fetching films: \(error)")
              labels["header"]! = "Error contacting Server (:"
              showAlert = true
            return
          }
          
          guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
              labels["header"]! = "Error contacting Server (:"
              showAlert = true
            return
          }

          if let data = data,
            let questions = try? JSONDecoder().decode([TriviaQuestion].self, from: data) {
              completionHandler(questions)
          }
        })
        task.resume()
      }
}

private func composeUrl(url: String) -> URL {
    let tmp = URL(string: url)!
    let queryItem = URLQueryItem(name: "count", value: "1")
    return tmp.appending(queryItems: [queryItem])
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
