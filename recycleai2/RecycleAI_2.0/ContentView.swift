//
//  File.swift
//  RecycleAI_2.0
//
//  Created by Morgan Lafferty on 4/22/21.
//


import SwiftUI
import UIKit
import Foundation
import CoreML
import CoreGraphics

public var quote: String = ""

struct ContentView: View {
   //public var quote:String
   
    var body: some View {
        NavigationView {
            ZStack{
             Text("Recycle.ai")
             .bold()
             .offset(y:-320)
             .font(.system(size:60))
             .foregroundColor(.white)
                
        
            NavigationLink(
                destination:SecondView().navigationBarBackButtonHidden(true),
                    label: {
                        Text("Get Started")
                            .bold()
                            .font(.system(size:30))
                            .foregroundColor(.white)
                    })
                    .padding(.leading, 30)
                    .padding(.trailing, 30)
                    .background(Color.green)
                    .position(x:200, y:620)
                
                /*Button("here") {
                    quote = parseCSVFacts()
                    print(quote)
                }.font(.system(size:30))
                .position(x:200, y:620)*/

                
            }
            .background(
             Image("Welcome Screen")
             .resizable()
            .offset(y:-50)
             .edgesIgnoringSafeArea(.all)
             .frame(width:UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .onTapGesture {
                    quote = parseCSVFacts()
                    print(quote)
                }

             )
          
        }
    }
}

struct SecondView:View {
    
    var body: some View {
        TabView{
            RecycleView()
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("recycle")
                }
            FactsView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("tips")
                }
        }.accentColor(.green)
    }
    
    struct RecycleView: View {
        var cities: Array<String> = ["Berkeley, CA", "Oakland, CA", "San Francisco, CA",
                                     "Alameda, CA", "Albany, CA", "Dublin, CA", "Emeryville, CA", "Fremont, CA",
                                     "Hayward, CA", "Livermore, CA", "Newark, CA", "Piedmont, CA", "Pleasanton, CA", "San Leandro, CA",
                                     "Union City, CA", "Anitoch, CA", "Bay Point, CA", "Brentwood, CA", "Concord, CA", "Danville, CA",
                                    "El Cerrito, CA", "Hercules, CA", "Lafayette, CA", "Martinez, CA", "Orinda, CA", "Pittsburg, CA",
                                    "Pleasant Hill, CA", "Richmond, CA", "San Pablo, CA", "San Ramon, CA", "Walnut Creek, CA", "Corte Madera,CA",
                                    "Larkspur, CA", "Mill Valley, CA", "Novato, CA", "San Anselmo, CA", "San Rafael, CA", "Sausalito, CA", "Tiburon, CA", "Napa, CA", "Yountville, CA", "St. Helena, CA", "Brisbane, CA", "Burlingame, CA", "Daly City, CA", "Foster City, CA"]
        @State private var selectedCity: String = "Berkeley, CA"
        @State var showPopUpTrue: Bool = false
        @State var showPopUpFalse: Bool = false
        @State private var image: Image?
        @State private var showingImagePicker: Bool = false
        @State private var inputImage: UIImage?
        @State private var croppedImage: UIImage?
        @State private(set) var sourceType: ImagePicker.SourceType = .photoLibrary
        @State var number: Int = 0
        @State var index: Int = 0
        @State private var x: NSNumber = 0
        @State private var y: NSNumber = 0
        @State private var width: NSNumber = 0
        @State private var height: NSNumber = 0
        
        //@State var line: Lin
        //@ State private var odcoorinates: MultiArray(Double 0 x 4)
        /* figure out how to set this index!! */
       
        let model = try! MyObjectDetector3_1()
        let cnn_model = try! cnn2()
        
          
        var body: some View {
            VStack{
                ZStack{
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(width: 350, height:350)
                        .position(x:195, y:90)
                        
                    //User has inputted an image
                    if image != nil {
                        
                        //let resizedImage = image?.resizeTo(size: CGSize(width: 299, height: 299))
                        //let buffer = CVPixelBuffer = (resizedImage?.toBuffer())!
                        
                       // let output =
                        image?
                            .resizable()
                            .frame(width: 350, height:350)
                            .position(x:195, y:90)
                            /*.overlay(GeometryReader{ (geometry: GeometryProxy) in
                            Rectangle()
                            .path(in: CGRect(
                                    x: CGFloat(self.x) * self.inputImage!.size.width , y: CGFloat(self.y)*self.inputImage!.size.height, width: CGFloat(self.width) * self.inputImage!.size.width, height: CGFloat(self.height) * self.inputImage!.size.height)).stroke(Color.red)
                                
                           })*/

                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }.onTapGesture {
                    /* add image*/
                    self.showingImagePicker = true
                }
                
               
                Text("Please Select Location")
                    .bold()
                    .foregroundColor(.white)
                    .font(.system(size:30))
                    .position(x:200, y:150)
                    
                
                Picker("Please choose a city", selection: $selectedCity) {
                    ForEach(self.cities, id: \.self) {
                        city in Text(city).tag(city)
                    }
                    
                }
                .opacity(1.5)
                .padding(.top, -85)
                .padding(.bottom, -40)
                .position(x:200, y:120)
                .sheet(isPresented: $showingImagePicker,
                        onDismiss: loadImage) {
                    ImagePicker(sourceType: self.sourceType, image: self.$inputImage)
                
            }
                Button(
                   action: {
                    
                    quote = parseCSVFacts()
                    print(quote)
                
                    
                        //let city = self.selectedCity
                    let list = parseCSV(city: self.selectedCity)
                    print(self.selectedCity)
                        //print(self.index)
                    print(list)
                   
                    
                    
                    /*
                    call model on self.$inputImage*/
                    
                    
                    let resizedImage = inputImage?.resizeTo(size: CGSize(width: 299 , height: 299 ))
                    let buffer: CVPixelBuffer = (resizedImage?.toBuffer())!
                        
                    let output = try? model.prediction(image: buffer, iouThreshold: 0.33, confidenceThreshold: 0.40)
                    let coords = Array(arrayLiteral: output?.coordinates)
                    self.x = coords[0]![0]
                    self.y = coords[0]![1]
                    self.width = coords[0]![2]
                    self.height = coords[0]![3]
                    
                    //replace current image with new image and bounding boxes
                    /*self.image = Image(uiImage: self.inputImage!)
                        .resizable()
                        .scaledToFit()
                        .overlay(GeometryReader{ geometry in
                         Rectangle()
                             .path(in: CGRect(
                                 x:00.51 * geometry.size.width, y: 00.508 * geometry.size.height, width: 00.799 * geometry.size.width, height: 00.907 * geometry.size.height)).stroke(Color.red)
                         
                     })*/
                    
                    //self.image = Image("checkmark")
                    let croppedImage = cropImage(imageToCrop: self.inputImage!, toRect: CGRectMake(x: CGFloat(self.x), y: CGFloat(self.y), width: CGFloat(self.width), height: CGFloat(self.height)))
                    //self.image = self.$croppedImage
                    ImagePicker(sourceType: self.sourceType, image: self.$croppedImage)
                    //print(croppedImage)
                   
                
                        
                    //resize image for classification
                    let resizedImage2 = inputImage?.resizeTo(size: CGSize(width: 200 , height: 200))
                    let pixelbuffer = resizedImage2?.toBuffer()
                    
                    //make the classifcation prediction
                    guard let prediction = try? cnn_model.prediction(rescaling_5_input: pixelbuffer!) else {return}
                    //accessing classifcation
                    let classifications = prediction.Identity.self
                    print(classifications)
                    
                    //Finding index of classification with argmax
                    let tuple = argmax(classifications, start: 0, stop: 6)
                    let amax = tuple.maxIndex + 1
                    self.number = amax
                    
                    //self.number = argmax + 1
                    print(self.number)
                        
                    if list![self.number ] == "TRUE" {
                            self.showPopUpTrue.toggle()
                            
                   }
                    else {
                            
                            self.showPopUpFalse.toggle()
                        }
                    }) {
                    Text("Go!")
                        .bold()
                        .foregroundColor(.white)
                        .font(.system(size:30))
                    }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .background(Color.green)
                .position(x:200, y:80)
                
                if $showPopUpTrue.wrappedValue {
                    ZStack(alignment: .center) {
                        Color.white
                        VStack {
                            Image("checkmark")
                                .resizable()
                                .frame(width: 220, height: 220)
                                .position(x: 176, y: 180)
                            Text("Please Recycle!").foregroundColor(.green)
                                .bold()
                                .font(.system(size: 44))
                                .position(x:176, y: 150)
                            Spacer()
                            let string: String = "Number " + String(self.number) + " plastics can be recycled in " + self.selectedCity + "!"
                            Text(string)
                                .font(.system(size: 20))
                                .foregroundColor(.green)
                                .position(x:164, y: 50)
                                .padding(.leading, 10)
                                .multilineTextAlignment(.center)
                            Button(action: {
                                self.showPopUpTrue = false
                            }) {
                                Text("ok")
                                    .font(.system(size: 24)).multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                   
                            }.padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                            .background(Color.green)
                        }
                    }.frame(width: 350, height: 610)
                    .cornerRadius(20).shadow(radius:20)
                    .position(x: 195, y: -270)
                }
                
                if $showPopUpFalse.wrappedValue {
                    ZStack(alignment: .center) {
                        Color.white
                        VStack {
                            Image("xmark")
                                .resizable()
                                .frame(width: 220, height: 220)
                                .position(x: 176, y: 180)

                            Text("Do Not Recycle!").foregroundColor(.red)
                                .bold()
                                .font(.system(size: 40))
                                .position(x:176, y: 150)
                            Spacer()
                            let string2: String = "Number " + String(self.number) + " plastics can not be recycled in " + self.selectedCity + "! This item belongs in the trash."
                            Text(string2)
                            //Text("Number " + String(self.number) + " plastics can not be recycled in " + String(self.selectedCity) + ". This item belongs in the trash!")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                                .position(x:164, y: 50)
                                .padding(10)
                                .multilineTextAlignment(.center)
                            Button(action: {
                                self.showPopUpFalse = false
                            }) {
                                Text("ok")
                                    .font(.system(size: 24)).multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                   
                            }.padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                            .background(Color.red)
                        }
                    }.frame(width: 350, height: 610)
                    .cornerRadius(20).shadow(radius:20)
                    .position(x: 195, y: -270)
                    
                }
                
            }
                .background(
                Image("recycle background2")
                .resizable()
                /*.offset(y:5)*/
                .edgesIgnoringSafeArea(.all)
                .frame(width:UIScreen.main.bounds.width,
                       height: UIScreen.main.bounds.height)
            )
            
            
        }
        func loadImage() {
            guard let inputImage = inputImage else {return}
            image = Image(uiImage: inputImage)
        }
    }
    /*struct LocationView: View {
        var body: some View {
            
    }*/

    struct FactsView: View {
       
        var body: some View {
            ZStack{
                Image("symbol")
                    .resizable()
                    .frame(width:200, height: 200)
                    .position(x:196, y:40)
                Text("Tip of the Day")
                    .bold()
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .position(x:196, y:190)
                
                Text(quote)
                    .foregroundColor(.white)
                    .font(.system(size: 35))
                    .multilineTextAlignment(.center)
                    .frame(width: 350)
                    .position(x:196, y:410)
                
            }.background(
            Image("recycle background2")
                .resizable()
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                .frame(width:UIScreen.main.bounds.width,
                       height: UIScreen.main.bounds.height))
            }
        }
    }




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
            /*ContentView(
            )*/
        SecondView.RecycleView()
       /* SecondView.FactsView()*/
    }
}


