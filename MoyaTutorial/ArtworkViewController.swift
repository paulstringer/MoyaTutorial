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

import UIKit

class ArtworkViewController: UIViewController {
  
  @IBOutlet var segmentedControl: UISegmentedControl!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var tagsView: UIView!
  
  var tagsViewController: TagsViewController!
  var artwork: Artwork!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadArtImage()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    tagsViewController = segue.destination as! TagsViewController
  }
  
  private func loadArtImage() {
    ArtsyAPIManager().image(for: artwork, completion: { (image, errorDescription) in
      self.segmentedControl.setEnabled(true, forSegmentAt: 1)
      self.updateImage(with: image)
    })
  }
  
  private func updateImage(with image: UIImage?) {
    self.imageView.image = image
    self.tagsViewController.image = self.imageView.image
  }
  
  @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      imageView.isHidden = false
      tagsView.isHidden = true
      return
    case 1:
      imageView.isHidden = true
      tagsView.isHidden = false
      return
    default:
      return
    }
  }

}
