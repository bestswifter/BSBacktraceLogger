//
//  ViewController.swift
//  Examples
//
//  Created by Ruswan Efendi on 29/03/22.
//  Copyright © 2022 Ruswan Efendi. All rights reserved.
//

import UIKit
import BSBacktraceLogger

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		runPingThread()
		runLoop()
	}

	private func runPingThread() {
		
		let thread = Thread {
			while(true) {
				
				guard let backtrace = BSLogger.bs_backtraceOfMainThread() else {
					return
				}
				
				let traces = backtrace.split(separator: "\n")
				
				let parsedTraces = traces.compactMap({ trace -> (symbol: String, file: String, line: Int)? in
					let contents = trace.split(separator: " ")
					
					if contents.count < 5 {
						return nil
					}
					
					let fileName = String(contents[0])
					let symbol = contents[2..<(contents.count - 2)].joined(separator: " ")
					let line = (Int(contents[contents.count - 1]) ?? 0)
					
					return (symbol: symbol, file: fileName, line: line)
				})
				
				dump(parsedTraces)
			}
		}
		
		thread.start()
	}
	
	private func runLoop() {
		while(true) {
			Thread.sleep(forTimeInterval: 2)
		}
	}
}

