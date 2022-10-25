//
//  SwiftUIView.swift
//  Client
//
//  Created by Vladimir Petrov on 04/04/2022.
//

import SwiftUI
import Combine

private class MessagesViewModel: ObservableObject {
  let service = WSSService()
  @Published var messages: [Message] = []

  @Published var messageText = ""
  @Published var name = ""
  @Published var isConnected = false

  var cancellable = Set<AnyCancellable>()

  init() {
    service.messagesPublisher
      .map { Message.createArray(from: $0) }
      .assign(to: \.messages, on: self)
      .store(in: &cancellable)
    service.isConnected
      .assign(to: \.isConnected, on: self)
      .store(in: &cancellable)
  }

  func send() {
    service.sendMessage(messageText)
    messageText = ""
  }

  func start() {
    service.start(name: name)
  }

  func logout() {
    service.disconnect()
  }
}

struct SwiftUIView: View {

  @StateObject fileprivate var viewModel = MessagesViewModel()

  var body: some View {
    VStack {
      HStack {
        TextField("Name", text: $viewModel.name)
          .foregroundColor(viewModel.isConnected ? .gray : .black)
          .disabled(viewModel.isConnected)
        Button {
          viewModel.start()
        } label: {
          Text("LogIn")
        }
        .disabled(viewModel.isConnected)
        Button {
          viewModel.logout()
        } label: {
          Text("LogOut")
        }
        .disabled(!viewModel.isConnected)
      }
      .padding()
      if viewModel.isConnected {
        Form {
          List(viewModel.messages) { message in
            MessageItem(message: message)
          }
        }
        .animation(
          .easeOut(duration: 0.3),
          value: viewModel.messages
        )
      } else {
        Spacer()
        Text("No connection 😱")
        Spacer()
      }
      HStack {
        TextField("Message...", text: $viewModel.messageText)
        Button {
          viewModel.send()
        } label: {
          Text("Send")
        }

      }
      .padding()
      .disabled(!viewModel.isConnected)
    }
    .navigationTitle("Anonymus Dyno Chat")
  }
}

struct MessageItem: View {

  let message: Message

  var body: some View {
    VStack {
      HStack {
        Text(message.authorName)
          .font(.footnote)
          .foregroundColor(message.isCurrentUser ? .accentColor : .gray)
          .padding(.zero)
        Spacer()
        if message.isCurrentUser {
          Text("(You)")
        }
      }
      HStack {
        Text(message.text)
          .font(.body)
        Spacer()
      }
    }
  }
}

struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    SwiftUIView()
  }
}
