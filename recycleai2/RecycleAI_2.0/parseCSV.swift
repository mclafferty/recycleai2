//
//  parseCSV.swift
//  RecycleAI_2.0
//
//  Created by Morgan Lafferty on 4/25/21.
//


import Foundation
//import SwiftCSV

func parseCSV(city: String) -> [String]?{
    var list: [String]? = ["Berkeley, CA", "TRUE", "TRUE", "FALSE", "FALSE", "TRUE", "FALSE", "FALSE"]
    let mapping = [
        "Berkeley, CA": 0, "Oakland, CA": 1, "San Francisco, CA": 2, "Alameda, CA": 3, "Albany, CA": 4, "Dublin, CA": 5, "Emeryville, CA": 6, "Fremont, CA": 7,
        "Hayward, CA": 8, "Livermore, CA": 9, "Newark, CA": 10, "Piedmont, CA": 11, "Pleasanton, CA": 12, "San Leandro, CA": 13, "Union City, CA": 14, "Anitoch, CA": 15, "Bay Point, CA": 16, "Brentwood, CA": 17, "Concord, CA": 18, "Danville, CA": 19, "El Cerrito, CA":20, "Hercules, CA":21, "Lafayette, CA": 22, "Martinez, CA":23, "Orinda, CA":24, "Pittsburg, CA":25,"Pleasant Hill, CA": 26, "Richmond, CA": 27, "San Pablo, CA": 28, "San Ramon, CA": 29, "Walnut Creek, CA": 30, "Corte Madera,CA": 31,"Larkspur, CA": 32, "Mill Valley, CA": 33, "Novato, CA": 34, "San Anselmo, CA":35, "San Rafael, CA": 36, "Sausalito, CA":37, "Tiburon, CA":38, "Napa, CA":39, "Yountville, CA":40, "St. Helena, CA":41, "Brisbane, CA":42, "Burlingame, CA":43, "Daly City, CA":44, "Foster City, CA":45]
    do {
        let csv: CSV? = try CSV(
            name: "Recycle AI Recycling Codes - Sheet1",
            extension: "tsv",
            bundle: .main,
            delimiter: "\t"
        )
        /* read data*/
        let i = mapping[city]
        print(i)
        print(city)
        list = csv?.enumeratedRows[i!] //[1...]
        
    } catch {
        list = nil
        print("error")
    }
    
   return list
}

func parseCSVFacts() -> String {
    var quote: String
    var aQuote: String = "Becuase it's become increasingly challenging to find buyers for the recycled raw materials of plastics #3-7, even post recycling, these products will get stockpiled or sent to a landfill. Purchasing products in highly recyclable materials like glass, metal, and plastics #1-2 will help reduce your environmental impact!"
    do {
        let csv: CSV? = try CSV(
            name: "Tips",
            extension: "tsv",
            bundle: .main,
            delimiter: "\t"
        )
        let quotes = csv?.enumeratedRows
        print(quotes)
        var i = Int.random(in: 0..<quotes!.count)
        print(i)
        aQuote = quotes![i][0]
        print("aQuote", aQuote)
        

    } catch {
        print("error")
    }
    return aQuote
}
 
