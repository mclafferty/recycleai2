//
//  parseCSV.swift
//  RecycleAI_2.0
//
//  Created by Morgan Lafferty on 4/25/21.
//

import Foundation

//read city .tsv data file
func parseCSV(city: String) -> [String]?{
    var list: [String]? = ["Berkeley, CA", "TRUE", "TRUE", "FALSE", "FALSE", "TRUE", "FALSE", "FALSE"]
    
    let mapping = ["Alameda, CA": 0, "Albany, CA": 1, "Antioch, CA": 2, "Bay Point, CA": 3, "Benicia, CA": 4, "Berkeley, CA": 5, "Brentwood, CA": 6,
                   "Brisbane, CA": 7, "Burlingame, CA": 8, "Campbell, CA": 9, "Concord, CA": 10, "Corte Madera, CA": 11, "Cupertino, CA": 12, "Daly City, CA": 13,
                   "Danville, CA": 14, "Dixon, CA": 15, "Dublin, CA": 16, "El Cerrito, CA": 17, "Emeryville, CA": 18, "Fairfield, CA": 19, "Foster City, CA": 20,
                   "Fremont, CA": 21, "Gilroy, CA": 22, "Half Moon Bay, CA": 23, "Hayward, CA": 24, "Healdsburg, CA": 25, "Hercules, CA": 26, "Lafayette, CA": 27,
                   "Larkspur, CA": 28, "Livermore, CA": 29, "Los Altos, CA": 30, "Los Gatos, CA": 31, "Martinez, CA": 32, "Menlo Park, CA": 33, "Mill Valley, CA": 34,
                   "Millbrae, CA": 35, "Milpitas, CA": 36, "Morgan Hill, CA": 37, "Mountain View, CA": 38, "Napa, CA": 39, "Newark, CA": 40, "Novato, CA": 41,
                   "Oakland, CA": 42, "Orinda, CA": 43, "Palo Alto, CA": 44, "Petaluma, CA": 45, "Piedmont, CA": 46, "Pittsburg, CA": 47, "Pleasant Hill, CA": 48,
                   "Pleasanton, CA": 49, "Portola Valley, CA": 50, "Redwood City, CA": 51, "Richmond, CA": 52, "Rohnert Park, CA": 53, "San Anselmo, CA": 54, "San Bruno, CA": 55,
                   "San Carlos, CA": 56, "San Francisco, CA": 57, "San Jose, CA": 58, "San Leandro, CA": 59, "San Mateo, CA": 60, "San Pablo, CA": 61, "San Rafael, CA": 62,
                   "San Ramon, CA": 63, "Santa Clara, CA": 64, "Santa Rosa, CA": 65, "Saratoga, CA": 66, "Sausalito, CA": 67, "Sebastopol, CA": 68, "Sonoma, CA": 69, "South San Francisco, CA": 70,
                   "St. Helena, CA": 71, "Sunnyvale, CA": 72, "Tiburon, CA": 73, "Union City, CA": 74, "Vacaville, CA": 75, "Vallejo, CA": 76, "Walnut Creek, CA": 77, "Windsor, CA": 78,
                   "Woodside, CA": 79, "Yountville, CA": 80]
    
    do {
        let csv: CSV? = try CSV(
            name: "Recycle AI Recycling Codes - Sheet1",
            extension: "tsv",
            bundle: .main,
            delimiter: "\t"
        )
        //read data
        let i = mapping[city]
        list = csv?.enumeratedRows[i!]
        
    } catch {
        list = nil
        print("error")
    }
    
   return list
}

// ready recycling tips .tsv data file 
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
        var i = Int.random(in: 0..<quotes!.count)
        aQuote = quotes![i][0]
        

    } catch {
        print("error")
    }
    return aQuote
}
 
