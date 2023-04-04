//
//  RantimeError.swift
//  GraphicMotionApplication
//
//  Created by ICoon on 04.02.2022.
//  Copyright © 2022 ipinguin_linuxoid. All rights reserved.
//


//https://stackoverflow.com/questions/31443645/simplest-way-to-throw-an-error-exception-with-a-custom-message-in-swift
struct RuntimeError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}
