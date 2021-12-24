//
//  AppDatabase.swift
//  imink
//
//  Created by Jone Wang on 2020/9/14.
//

import Foundation
import Combine
import GRDB

class AppDatabase {
    static let shared = try! AppDatabase()
    
    internal let dbQueue: DatabaseQueue
    
    init() throws {
        let databaseURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
        
        #if DEBUG
        print("sqlite url: \(databaseURL.path)")
        #endif
        
        let dbQueue = try DatabaseQueue(path: databaseURL.path)
        
        self.dbQueue = dbQueue
        
        try migrator.migrate(dbQueue)
    }
    
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        #if DEBUG
//        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        migrator.registerMigration("createRecord") { db in
            // Create a table
            // See https://github.com/groue/GRDB.swift#create-tables
            try db.create(table: "record") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("sp2PrincipalId", .text).notNull()
                t.column("battleNumber", .text).notNull()
                t.column("json", .text).notNull()
                t.column("isDetail", .boolean).notNull().defaults(to: true)
                t.column("victory", .boolean).notNull()
                t.column("weaponImage", .text).notNull()
                t.column("rule", .text).notNull()
                t.column("gameMode", .text).notNull()
                t.column("stageName", .text).notNull()
                t.column("killTotalCount", .integer).notNull()
                t.column("deathCount", .integer).notNull()
                t.column("myPoint", .double).notNull()
                t.column("otherPoint", .double).notNull()
            }
        }
        
        migrator.registerMigration("V2") { db in
            try db.alter(table: "record", body: { tableAlteration in
                tableAlteration.add(column: "killCount", .integer).defaults(to: 0).notNull()
                tableAlteration.add(column: "assistCount", .integer).defaults(to: 0).notNull()
                tableAlteration.add(column: "specialCount", .integer).defaults(to: 0).notNull()
                tableAlteration.add(column: "gamePaintPoint", .integer).defaults(to: 0).notNull()
                tableAlteration.add(column: "syncDetailTime", .datetime)
            })
            
            try self.eachBattles(db: db) { (id, battle) in
                try db.execute(
                    sql: "UPDATE record SET " +
                        "killCount = :killCount, " +
                        "assistCount = :assistCount, " +
                        "specialCount = :specialCount, " +
                        "gamePaintPoint = :gamePaintPoint, " +
                        "syncDetailTime = :syncDetailTime " +
                        "WHERE id = :id",
                    arguments: [
                        "killCount": battle.playerResult.killCount,
                        "assistCount": battle.playerResult.assistCount,
                        "specialCount": battle.playerResult.specialCount,
                        "gamePaintPoint": battle.playerResult.gamePaintPoint,
                        "syncDetailTime": Date(),
                        "id": id
                    ])
            }
        }
        
        migrator.registerMigration("V3") { db in
            try db.alter(table: "record", body: { tableAlteration in
                tableAlteration.add(column: "gameModeKey", .text).defaults(to: "").notNull()
                tableAlteration.add(column: "startDateTime", .datetime).defaults(to: Date()).notNull()
            })
            
            try self.eachBattles(db: db) { (id, battle) in
                try db.execute(
                    sql: "UPDATE record SET " +
                        "gameModeKey = :gameModeKey, " +
                        "startDateTime = :startDateTime " +
                        "WHERE id = :id",
                    arguments: [
                        "gameModeKey": battle.gameMode.key.rawValue,
                        "startDateTime": battle.startTime,
                        "id": id
                    ])
            }
        }
        
        migrator.registerMigration("V4") { db in
            try db.alter(table: "record", body: { tableAlteration in
                tableAlteration.add(column: "udemaeName", .text)
                tableAlteration.add(column: "udemaeSPlusNumber", .integer)
                tableAlteration.add(column: "type", .text).defaults(to: "").notNull()
                tableAlteration.add(column: "leaguePoint", .double)
                tableAlteration.add(column: "estimateGachiPower", .integer)
                tableAlteration.add(column: "playerTypeSpecies", .text).defaults(to: "").notNull()
            })
            
            try self.eachBattles(db: db) { (id, battle) in
                try db.execute(
                    sql: "UPDATE record SET " +
                        "udemaeName = ?, " +
                        "udemaeSPlusNumber = ?, " +
                        "type = ?, " +
                        "leaguePoint = ?, " +
                        "estimateGachiPower = ?, " +
                        "playerTypeSpecies = ? " +
                        "WHERE id = ?",
                    arguments: [
                        battle.udemae?.name,
                        battle.udemae?.sPlusNumber,
                        battle.type,
                        battle.leaguePoint,
                        battle.estimateGachiPower,
                        battle.playerResult.player.playerType.species,
                        id
                    ])
            }
        }
        
        migrator.registerMigration("V5") { db in
            try self.eachBattles(db: db) { (id, battle) in
                try db.execute(
                    sql: "UPDATE record SET " +
                        "udemaeName = ?, " +
                        "udemaeSPlusNumber = ? " +
                        "WHERE id = ?",
                    arguments: [
                        battle.udemae?.name,
                        battle.udemae?.sPlusNumber,
                        id
                    ])
            }
        }
        
        migrator.registerMigration("V6") { db in
            try DBRecord.filter(DBRecord.Columns.isDetail == false)
                .deleteAll(db)
        }
        
        migrator.registerMigration("createJob") { db in
            try db.create(table: "job") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("sp2PrincipalId", .text).notNull()
                t.column("jobId", .integer).notNull()
                t.column("json", .text).notNull()
                t.column("isClear", .boolean).notNull()
                t.column("gradePoint", .integer).notNull()
                t.column("gradePointDelta", .integer).notNull()
                t.column("gradeId", .text).notNull()
                t.column("helpCount", .integer).notNull()
                t.column("deadCount", .integer).notNull()
                t.column("goldenIkuraNum", .integer).notNull()
                t.column("ikuraNum", .integer).notNull()
                t.column("failureWave", .integer)
                t.column("dangerRate", .double).notNull()
            }
        }
        
        migrator.registerMigration("V7") { db in
            try db.alter(table: "record", body: { tableAlteration in
                tableAlteration.add(column: "weaponId", .text).defaults(to: "0").notNull()
            })
            
            try self.eachBattles(db: db) { (id, battle) in
                try db.execute(
                    sql: "UPDATE record SET " +
                        "weaponId = ?, " +
                        "udemaeName = ?, " +
                        "udemaeSPlusNumber = ? " +
                        "WHERE id = ?",
                    arguments: [
                        battle.playerResult.player.weapon.id,
                        battle.udemae?.name,
                        battle.udemae?.sPlusNumber,
                        id
                    ])
            }
            
            try db.alter(table: "job", body: { tableAlteration in
                tableAlteration.add(column: "scheduleStartTime", .datetime).defaults(to: Date()).notNull()
                tableAlteration.add(column: "scheduleEndTime", .datetime).defaults(to: Date()).notNull()
                tableAlteration.add(column: "scheduleStageName", .text).defaults(to: "").notNull()
                tableAlteration.add(column: "scheduleWeapon1Id", .text).defaults(to: "").notNull()
                tableAlteration.add(column: "scheduleWeapon1Image", .text).defaults(to: "").notNull()
                tableAlteration.add(column: "scheduleWeapon2Id", .text).defaults(to: "").notNull()
                tableAlteration.add(column: "scheduleWeapon2Image", .text).defaults(to: "").notNull()
                tableAlteration.add(column: "scheduleWeapon3Id", .text).defaults(to: "").notNull()
                tableAlteration.add(column: "scheduleWeapon3Image", .text).defaults(to: "").notNull()
                tableAlteration.add(column: "scheduleWeapon4Id", .text).defaults(to: "").notNull()
                tableAlteration.add(column: "scheduleWeapon4Image", .text).defaults(to: "").notNull()
            })
            
            try self.eachJobs(db: db) { (id, job) in
                try db.execute(
                    sql: "UPDATE job SET " +
                        "scheduleStartTime = ?, " +
                        "scheduleEndTime = ?, " +
                        "scheduleStageName = ?, " +
                        "scheduleWeapon1Id = ?, " +
                        "scheduleWeapon1Image = ?, " +
                        "scheduleWeapon2Id = ?, " +
                        "scheduleWeapon2Image = ?, " +
                        "scheduleWeapon3Id = ?, " +
                        "scheduleWeapon3Image = ?, " +
                        "scheduleWeapon4Id = ?, " +
                        "scheduleWeapon4Image = ? " +
                        "WHERE id = ?",
                    arguments: [
                        job.schedule.startTime,
                        job.schedule.endTime,
                        job.schedule.stage?.name ?? "",
                        job.schedule.weapons?[0].id ?? "",
                        job.schedule.weapons?[0].weapon?.$image ?? "",
                        job.schedule.weapons?[1].id ?? "",
                        job.schedule.weapons?[1].weapon?.$image ?? "",
                        job.schedule.weapons?[2].id ?? "",
                        job.schedule.weapons?[2].weapon?.$image ?? "",
                        job.schedule.weapons?[3].id ?? "",
                        job.schedule.weapons?[3].weapon?.$image ?? "",
                        id
                    ])
            }
        }
        
        migrator.registerMigration("V8") { db in
            try db.alter(table: "record", body: { tableAlteration in
                tableAlteration.add(column: "isX", .boolean)
                tableAlteration.add(column: "xPower", .double)
            })
            
            try self.eachBattles(db: db) { (id, battle) in
                try db.execute(
                    sql: "UPDATE record SET " +
                        "isX = ?, " +
                        "xPower = ? " +
                        "WHERE id = ?",
                    arguments: [
                        battle.udemae?.isX ?? false,
                        battle.xPower,
                        id
                    ])
            }
        }
        
        migrator.registerMigration("V9") { db in
            try db.execute(
                sql: "UPDATE record SET " +
                    "isX = false " +
                    "WHERE isX is null"
            )
        }
        
        migrator.registerMigration("V10") { db in
            try db.alter(table: "record", body: { tableAlteration in
                tableAlteration.add(column: "ruleKey", .text).defaults(to: "turf_war").notNull()
            })
            
            try self.fastEachBattles(db: db) { (id, battle) in
                if let rule = battle["rule"] as? [String: Any],
                   let ruleKey = rule["key"] as? String {
                    try db.execute(
                        sql: "UPDATE record SET " +
                            "ruleKey = :ruleKey " +
                            "WHERE id = :id",
                        arguments: [
                            "ruleKey": ruleKey,
                            "id": id
                        ])
                }
            }
        }
        
        migrator.registerMigration("V11") { db in
            try db.alter(table: "record", body: { tableAlteration in
                tableAlteration.add(column: "stageId", .text).defaults(to: "0").notNull()
            })
            
            for (key, value) in stageMap {
                try db.execute(
                    sql: "UPDATE record SET " +
                        "stageId = ? " +
                        "WHERE stageName = ?",
                    arguments: [
                        value,
                        key
                    ]
                )
            }
        }
        
        return migrator
    }
}

extension AppDatabase {
    
    func fastEachBattles(db: Database, _ block: (Int64, [String: Any]) throws -> Void) throws {
        let rows = try Row.fetchCursor(db, sql: "SELECT id, json FROM record")
        while let row = try? rows.next() {
            guard let id = row["id"] as? Int64,
                  let json = row["json"] as? String,
                  let data = json.data(using: .utf8),
                  let battle = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                continue
            }
            
            try block(id, battle)
        }

    }
    
    func eachBattles(db: Database, _ block: (Int64, Battle) throws -> Void) throws {
        let rows = try Row.fetchCursor(db, sql: "SELECT id, json FROM record")
        while let row = try? rows.next() {
            guard let id = row["id"] as? Int64,
                  let json = row["json"] as? String else {
                continue
            }
            
            guard let battle = json.decode(Battle.self) else {
                continue
            }
            
            try block(id, battle)
        }
    }
    
    func eachJobs(db: Database, _ block: (Int64, Job) throws -> Void) throws {
        let rows = try Row.fetchCursor(db, sql: "SELECT id, json FROM job")
        while let row = try? rows.next() {
            guard let id = row["id"] as? Int64,
                  let json = row["json"] as? String else {
                continue
            }
            
            guard let job = json.decode(Job.self) else {
                continue
            }
            
            try block(id, job)
        }
    }
    
}

fileprivate let stageMap = [
    "Abyssal-Museum": 12,
    "Acciugames": 21,
    "Allées salées": 0,
    "Almacén Rodaballo": 14,
    "Ancho-V Games": 21,
    "Anchobit Games HQ": 21,
    "Ansjobit-gamestudio": 21,
    "Arena Sardina": 18,
    "Arowana Mall": 15,
    "Arowana-Center": 15,
    "Astillero Beluga": 3,
    "Auditorio Erizo": 2,
    "Backfisch-Stadion": 18,
    "Barrio Congrio": 0,
    "Blackbelly Skatepark": 11,
    "Buckelwal-Piste": 5,
    "Bultrugbazaar": 13,
    "Bバスパーク": 11,
    "Camp Schützenfisch": 16,
    "Camp Triggerfish": 16,
    "Campamento Arowana": 16,
    "Campeggio Totan": 16,
    "Campus Hippocampus": 4,
    "Canal Cormorán": 9,
    "Canalamar": 9,
    "Canale Cannolicchio": 9,
    "Canalmar": 9,
    "Cantera Tintorera": 17,
    "Cantiere Pinnenere": 3,
    "Carrière Caviar": 17,
    "Carrières Caviar": 17,
    "Centre Arowana": 15,
    "Centro commerciale": 15,
    "Centro polpisportivo": 1,
    "Cetacea-Markt": 13,
    "Chantier Narval": 3,
    "Corbeta Corvina": 6,
    "Docks Haddock": 7,
    "Encrepôt": 14,
    "Estadio Ajolote": 21,
    "Flunder-Funpark": 20,
    "Galerie des abysses": 12,
    "Galería Raspa": 12,
    "Gimnasio Mejillón": 1,
    "Goby Arena": 18,
    "Gran Hotel Caviar": 19,
    "Grondelgroeve": 17,
    "Grundel-Pavillon": 22,
    "Grätenkanal": 9,
    "Gymnase Ancrage": 1,
    "Hamerhaaihaven": 7,
    "Heilbutt-Hafen": 7,
    "Hippo-Camping": 16,
    "Hotel de Keizersvis": 19,
    "Hotel Neothun": 19,
    "Hotel Tellina": 19,
    "Humpback Pump Track": 5,
    "Hôtel Atoll": 19,
    "Inkblot Art Academy": 4,
    "Institut Calam'arts": 4,
    "Institut Calm'arts": 4,
    "Instituto Coralino": 4,
    "Jardín botánico": 10,
    "Kamp Karper": 16,
    "Kelp Dome": 10,
    "Kelpwierkas": 10,
    "Klipvisklipper": 6,
    "Kofferfisch-Lager": 14,
    "Koraalcampus": 4,
    "Korallenviertel": 0,
    "Lagune aux gobies": 22,
    "Lekkerbektrack": 5,
    "Magazzino": 14,
    "MakoMart": 13,
    "Manta Maria": 6,
    "Mercatotano": 13,
    "Miniera d'Orata": 17,
    "Moeraalkanaal": 9,
    "Molluskelbude": 1,
    "Moray Towers": 8,
    "Muränentürme": 8,
    "Museo paleontonnologico": 12,
    "Musselforge Fitness": 1,
    "New Albacore Hotel": 19,
    "Padiglione Capitone": 22,
    "Palco Plancton": 2,
    "Palingpaviljoen": 22,
    "Parc Carapince": 20,
    "Parque Lubina": 11,
    "Perlmutt-Akademie": 4,
    "Piranha Pit": 17,
    "Piranha Plaza": 15,
    "Pirañalandia": 20,
    "Pista Polposkate": 11,
    "Piste Méroule": 5,
    "Plancho Mako": 11,
    "Planktonstadion": 18,
    "Plate-forme polymorphe": 9999,
    "Plateforme polymorphe": 9999,
    "Plazuela del Calamar": 15,
    "Port Mackerel": 7,
    "Porto Polpo": 7,
    "Puerta del Gobio": 22,
    "Puerto Jurel": 7,
    "Punkasius-Skatepark": 11,
    "Rione Storione": 0,
    "Scène Sirène": 2,
    "Seeigel-Rockbühne": 2,
    "Serra di alghe": 10,
    "Serre Goémon": 10,
    "Shellendorf Institute": 12,
    "Shifty Station": 9999,
    "Skatepark Mako": 11,
    "Skipper Pavilion": 22,
    "Snapper Canal": 9,
    "Snoekduik-skatepark": 11,
    "Soglioland": 20,
    "Stade Bernique": 18,
    "Starfish Mainstage": 2,
    "Steinköhler-Grube": 17,
    "Sturgeon Shipyard": 3,
    "Störwerft": 3,
    "Supermarché Cétacé": 13,
    "Sushistraat": 0,
    "Tentatec Studio": 21,
    "The Reef": 0,
    "Tiburódromo": 5,
    "Tintodromo Montecarpa": 5,
    "Tonijntorens": 8,
    "Torres Merluza": 8,
    "Torri cittadine": 8,
    "Tours Girelle": 8,
    "Tümmlerkuppel": 10,
    "Ultramarinos Orca": 13,
    "Vinvis Fitness": 1,
    "Vistorisch museum": 12,
    "Wahoo World": 20,
    "Walleye Warehouse": 14,
    "Walruswerf": 3,
    "Wandelzone": 9999,
    "Waterwonderland": 20,
    "Wisselwereld": 9999,
    "Zeeleeuwloods": 14,
    "Zeesterrenstage": 2,
    "Zona mista": 9999,
    "«Горбуша-Маркет»": 13,
    "«Гуппи-Геймдев»": 21,
    "«Манта-Мария»": 6,
    "Área mutante": 9999,
    "Академия «Лепота»": 4,
    "Арена «Лужа»": 18,
    "База «Спинорог»": 16,
    "Велозал «9-й вал»": 5,
    "Инкрабсклад": 14,
    "КЗ «Иглокожий»": 2,
    "Луна-парк «Язь»": 20,
    "Музей «Мезозой»": 12,
    "Муренские башни": 8,
    "Осетровые верфи": 3,
    "Отель «Прибой»": 19,
    "Парк «Во Сток!»": 22,
    "Пираньев карьер": 17,
    "Подмостовье": 9,
    "Порт «Корюшка»": 7,
    "Риф": 0,
    "Скейт-парк «Скат»": 11,
    "Спортзал «Кревед!»": 1,
    "Транстанция": 9999,
    "Тц «Аравана»": 15,
    "Ферма ламинарии": 10,
    "アジフライスタジアム": 18,
    "アロワナモール": 15,
    "アンチョビットゲームズ": 21,
    "エンガワ河川敷": 9,
    "ガンガゼ野外音楽堂": 2,
    "コンブトラック": 5,
    "ザトウマーケット": 13,
    "ショッツル鉱山": 17,
    "スメーシーワールド": 20,
    "タチウオパーキング": 8,
    "チョウザメ造船": 3,
    "デボン海洋博物館": 12,
    "ハコフグ倉庫": 14,
    "バッテラストリート": 0,
    "フジツボスポーツクラブ": 1,
    "ホッケふ頭": 7,
    "ホテルニューオートロ": 19,
    "マンタマリア号": 6,
    "ミステリーゾーン": 9999,
    "ムツゴ楼": 22,
    "モズク農園": 10,
    "モンガラキャンプ場": 16,
    "海女美術大学": 4
  ]
