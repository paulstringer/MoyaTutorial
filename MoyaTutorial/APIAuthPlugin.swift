/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import Moya

struct AuthPlugin: PluginType {
  let header: String
  let token: String
}

extension AuthPlugin {
  func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
    var request = request
    request.addValue(token, forHTTPHeaderField: header)// "X-Xapp-Token")
    return request
  }
}


let ArtsyAuthPlugin = AuthPlugin(header: "X-Xapp-Token", token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6IiIsImV4cCI6MTUwNDY3OTU4NCwiaWF0IjoxNTA0MDc0Nzg0LCJhdWQiOiI1OThhY2U0MDJhODkzYTU5NWM0MWJkYWMiLCJpc3MiOiJHcmF2aXR5IiwianRpIjoiNTlhNjVjMjBjOWRjMjQwZWRkOTMzNmEwIn0.Vd6eJ1n1JWJd2IqDIKvyOJufiQ0V66FIET1yEyZdnSA")

let ImaggaAuthPlugin = AuthPlugin(header: "Authorization", token: "Basic YWNjXzEzNzcxMjU0NDI2ZmRlZDo3MjVkYzMxNWFiZGY4Mjg2ZmM2M2ViZDhhMDBiNDBkYQ==")