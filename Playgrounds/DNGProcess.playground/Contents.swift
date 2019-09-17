import Cocoa
import Quartz
import CoreImage
import CoreVideo

/* General References
 * CoreImage: https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_tasks/ci_tasks.html#//apple_ref/doc/uid/TP30001185-CH3-SW4
 * Developer's doc: https://developer.apple.com/documentation/coreimage/ciimage
 * From "sid" Project. Notebook iphonehid_CoreML2-CoreImage.ipynb
 *
 */

// This is needed to address a problem of CoreImage in Playgrounds
// from: https://stackoverflow.com/questions/50722950/swift-4-1-failed-to-get-a-bitmap-representation-of-this-nsimage

extension CIImage: CustomPlaygroundDisplayConvertible {
    static let playgroundRenderContext = CIContext()
    public var playgroundDescription: Any {
        let jpgData = CIImage.playgroundRenderContext.jpegRepresentation(of: self, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, options: [:])!
        return NSImage(data: jpgData)!
    }
}

// http://www.codingexplorer.com/creating-and-modifying-nsurl-in-swift/
var dngFile = "file:///Users/edm/tmp/DNG/1.dng"
var dngURL = NSURL(string:dngFile)
//print(dngURL!)

// Use CoreImage to load the RAW (DNG) file
let context = CIContext()

/* Some References
 * https://www.raywenderlich.com/2305-core-image-tutorial-getting-started
 * https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_tasks/ci_tasks.html#//apple_ref/doc/uid/TP30001185-CH3-TPXREF101
 */
// This will return an object of CIImage type
let RAWImage = CIImage(contentsOf: dngURL! as URL)
print(RAWImage!)
print(RAWImage!.description)

// This prints the properties of the image we just loaded.

print(RAWImage!.properties)
print(RAWImage!.properties.capacity)
print(RAWImage!.definition)      // <CIFilterShape: 0x7ffe081b49b0 extent [0 0 4032 3024]>
print(RAWImage!.self)
print(RAWImage!.extent)         // (0.0, 0.0, 4032.0, 3024.0)

var pixelBuffer : CVPixelBuffer? = nil

// Hard code, but these need to be obtained from the properties
// TODO - find out how to get width and height from image (using CoreImage)
let imageWidth = 3024
let imageHeight = 4032

CVPixelBufferCreate(kCFAllocatorDefault, imageWidth, imageHeight, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)
// https://developer.apple.com/documentation/coreimage/ciimage/1687604-pixelbuffer
// https://developer.apple.com/documentation/coreimage/cicontext/1437853-render
context.render(RAWImage!, to: pixelBuffer!)

// This should give me the underlying image
let ciImage: CIImage = CIImage(cvPixelBuffer: pixelBuffer!)  // CIImage: 0x7f84d1778d60 extent [0 0 4032 3024

// Investigate https://developer.apple.com/documentation/coreimage/ciimage/1687604-pixelbuffer

