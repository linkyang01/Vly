import Foundation
import CoreData

/// 智能分类服务 - 按类型/年份/评分、自定义标签
final class ClassificationService {
    static let shared = ClassificationService()
    
    private init() {}
    
    // MARK: - Built-in Categories
    
    /// 获取所有内置分类
    func getBuiltInCategories() -> [CategoryGroup] {
        [
            CategoryGroup(
                id: "type",
                name: "类型",
                icon: "film.fill",
                categories: [
                    Category(id: "action", name: "动作", icon: "figure.run", filter: .genre("动作")),
                    Category(id: "comedy", name: "喜剧", icon: "theatermasks.fill", filter: .genre("喜剧")),
                    Category(id: "drama", name: "剧情", icon: "person.2.fill", filter: .genre("剧情")),
                    Category(id: "horror", name: "恐怖", icon: "ghost.fill", filter: .genre("恐怖")),
                    Category(id: "scifi", name: "科幻", icon: "sparkles", filter: .genre("科幻")),
                    Category(id: "thriller", name: "惊悚", icon: "bolt.fill", filter: .genre("惊悚")),
                    Category(id: "romance", name: "爱情", icon: "heart.fill", filter: .genre("爱情")),
                    Category(id: "animation", name: "动画", icon: "paintbrush.fill", filter: .genre("动画")),
                    Category(id: "documentary", name: "纪录片", icon: "doc.text.fill", filter: .genre("纪录片"))
                ]
            ),
            CategoryGroup(
                id: "year",
                name: "年份",
                icon: "calendar",
                categories: [
                    Category(id: "2020s", name: "2020s", icon: "calendar", filter: .yearRange(2020, 2025)),
                    Category(id: "2010s", name: "2010s", icon: "calendar", filter: .yearRange(2010, 2019)),
                    Category(id: "2000s", name: "2000s", icon: "calendar", filter: .yearRange(2000, 2009)),
                    Category(id: "1990s", name: "1990s", icon: "calendar", filter: .yearRange(1990, 1999)),
                    Category(id: "classic", name: "经典老片", icon: "film.stack.fill", filter: .yearRange(1900, 1989))
                ]
            ),
            CategoryGroup(
                id: "rating",
                name: "评分",
                icon: "star.fill",
                categories: [
                    Category(id: "rating-9", name: "9分以上", icon: "star.fill", filter: .rating(9...10)),
                    Category(id: "rating-8", name: "8分以上", icon: "star.leadinghalf.filled", filter: .rating(8...10)),
                    Category(id: "rating-7", name: "7分以上", icon: "star", filter: .rating(7...10)),
                    Category(id: "rating-low", name: "7分以下", icon: "star.slash", filter: .rating(0.0...7.0))
                ]
            ),
            CategoryGroup(
                id: "status",
                name: "观看状态",
                icon: "eye.fill",
                categories: [
                    Category(id: "unwatched", name: "未观看", icon: "eye", filter: .status(.unwatched)),
                    Category(id: "inprogress", name: "观看中", icon: "play.circle", filter: .status(.inProgress)),
                    Category(id: "watched", name: "已观看", icon: "checkmark.circle.fill", filter: .status(.watched))
                ]
            )
        ]
    }
    
    // MARK: - Custom Tags
    
    /// 获取所有自定义标签
    func getAllCustomTags() -> [CustomTag] {
        let request = CustomTag.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CustomTag.name, ascending: true)]
        
        do {
            return try CoreDataManager.shared.viewContext.fetch(request)
        } catch {
            return []
        }
    }
    
    /// 创建自定义标签
    func createTag(name: String, icon: String = "tag.fill", color: String = "blue") -> CustomTag {
        let context = CoreDataManager.shared.viewContext
        let tag = CustomTag(context: context)
        tag.id = UUID()
        tag.name = name
        tag.icon = icon
        tag.color = color
        tag.createdAt = Date()
        
        try? context.save()
        return tag
    }
    
    /// 删除自定义标签
    func deleteTag(_ tag: CustomTag) {
        let context = CoreDataManager.shared.viewContext
        context.perform {
            context.delete(tag)
            try? context.save()
        }
    }
    
    /// 更新自定义标签
    func updateTag(_ tag: CustomTag, name: String? = nil, icon: String? = nil, color: String? = nil) {
        let context = CoreDataManager.shared.viewContext
        context.perform {
            if let name = name { tag.name = name }
            if let icon = icon { tag.icon = icon }
            if let color = color { tag.color = color }
            try? context.save()
        }
    }
    
    /// 为电影添加标签
    func addTag(_ tag: CustomTag, to movie: Movie) {
        let context = CoreDataManager.shared.viewContext
        context.perform {
            tag.addToMovies(movie)
            try? context.save()
        }
    }
    
    /// 从电影移除标签
    func removeTag(_ tag: CustomTag, from movie: Movie) {
        let context = CoreDataManager.shared.viewContext
        context.perform {
            tag.removeFromMovies(movie)
            try? context.save()
        }
    }
    
    /// 获取电影的所有标签
    func getTags(for movie: Movie) -> [CustomTag] {
        guard let tags = movie.customTags as? Set<CustomTag> else { return [] }
        return tags.sorted { $0.name < $1.name }
    }
    
    /// 获取包含指定标签的所有电影
    func getMovies(with tag: CustomTag) -> [Movie] {
        guard let movies = tag.movies as? Set<Movie> else { return [] }
        return movies.sorted { $0.title < $1.title }
    }
    
    // MARK: - Smart Filters
    
    /// 创建智能过滤器
    func createSmartFilter(name: String, criteria: [FilterCriteria]) -> SmartFilter {
        let context = CoreDataManager.shared.viewContext
        let filter = SmartFilter(context: context)
        filter.id = UUID()
        filter.name = name
        filter.criteriaData = try? JSONEncoder().encode(criteria)
        filter.createdAt = Date()
        
        try? context.save()
        return filter
    }
    
    /// 执行智能过滤
    func executeFilter(_ filter: SmartFilter) -> [Movie] {
        guard let criteriaData = filter.criteriaData,
              let criteria = try? JSONDecoder().decode([FilterCriteria].self, from: criteriaData) else {
            return []
        }
        return executeCriteria(criteria)
    }
    
    /// 执行过滤条件
    func executeCriteria(_ criteria: [FilterCriteria]) -> [Movie] {
        let request = Movie.fetchRequest()
        var predicates: [NSPredicate] = []
        let calendar = Calendar.current
        
        for criteriaItem in criteria {
            switch criteriaItem {
            case .genre(let name):
                predicates.append(NSPredicate(format: "ANY genres.name == %@", name))
            case .genreNot(let name):
                predicates.append(NSPredicate(format: "NOT ANY genres.name == %@", name))
            case .rating(let range):
                predicates.append(NSPredicate(format: "rating >= %@ AND rating < %@", 
                    NSNumber(value: range.lowerBound), NSNumber(value: range.upperBound)))
            case .year(let year):
                guard let startDate = calendar.date(from: DateComponents(year: year)),
                      let endDate = calendar.date(byAdding: .year, value: 1, to: startDate) else { continue }
                predicates.append(NSPredicate(format: "releaseDate >= %@ AND releaseDate < %@", 
                    startDate as NSDate, endDate as NSDate))
            case .yearRange(let start, let end):
                guard let startDate = calendar.date(from: DateComponents(year: start)),
                      let endDate = calendar.date(from: DateComponents(year: end + 1)) else { continue }
                predicates.append(NSPredicate(format: "releaseDate >= %@ AND releaseDate < %@", 
                    startDate as NSDate, endDate as NSDate))
            case .status(let status):
                switch status {
                case .unwatched:
                    predicates.append(NSPredicate(format: "isWatched == NO AND currentPosition == 0"))
                case .inProgress:
                    predicates.append(NSPredicate(format: "currentPosition > 0 AND isWatched == NO"))
                case .watched:
                    predicates.append(NSPredicate(format: "isWatched == YES"))
                }
            case .tag(let tagName):
                predicates.append(NSPredicate(format: "ANY customTags.name == %@", tagName))
            case .duration(let range):
                predicates.append(NSPredicate(format: "runtime >= %d AND runtime <= %d", 
                    range.lowerBound, range.upperBound))
            case .titleContains(let text):
                predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", text))
            case .watchCountAtLeast(let count):
                predicates.append(NSPredicate(format: "watchCount >= %d", count))
            case .recentlyAdded(let days):
                guard let date = calendar.date(byAdding: .day, value: -days, to: Date()) else { continue }
                predicates.append(NSPredicate(format: "addedDate >= %@", date as NSDate))
            }
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Movie.title, ascending: true)]
        
        do {
            return try CoreDataManager.shared.viewContext.fetch(request)
        } catch {
            return []
        }
    }
    
    // MARK: - Collection Management
    
    /// 获取所有集合
    func getAllCollections() -> [MovieCollection] {
        let request = MovieCollection.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MovieCollection.name, ascending: true)]
        
        do {
            return try CoreDataManager.shared.viewContext.fetch(request)
        } catch {
            return []
        }
    }
    
    /// 获取电影集合
    func getMovies(in collection: MovieCollection) -> [Movie] {
        guard let movies = collection.movies as? Set<Movie> else { return [] }
        return movies.sorted { $0.title < $1.title }
    }
    
    /// 按评分分组
    func getMoviesGroupedByRating() -> [String: [Movie]] {
        let movies = (try? CoreDataManager.shared.viewContext.fetch(Movie.fetchRequest())) ?? []
        var grouped: [String: [Movie]] = [
            "9+": [],
            "8-9": [],
            "7-8": [],
            "6-7": [],
            "<6": []
        ]
        
        for movie in movies {
            let rating = movie.rating
            switch rating {
            case 9..<10:
                grouped["9+"]?.append(movie)
            case 8..<9:
                grouped["8-9"]?.append(movie)
            case 7..<8:
                grouped["7-8"]?.append(movie)
            case 6..<7:
                grouped["6-7"]?.append(movie)
            default:
                grouped["<6"]?.append(movie)
            }
        }
        
        return grouped
    }
    
    /// 按年份分组
    func getMoviesGroupedByYear() -> [Int: [Movie]] {
        let movies = (try? CoreDataManager.shared.viewContext.fetch(Movie.fetchRequest())) ?? []
        var grouped: [Int: [Movie]] = [:]
        let calendar = Calendar.current
        
        for movie in movies {
            guard let releaseDate = movie.releaseDate else { continue }
            let year = calendar.component(.year, from: releaseDate)
            grouped[year, default: []].append(movie)
        }
        
        return grouped
    }
}

// MARK: - Supporting Types

enum WatchStatus: String, Codable {
    case unwatched
    case inProgress
    case watched
}

struct CategoryGroup: Identifiable {
    let id: String
    let name: String
    let icon: String
    let categories: [Category]
}

struct Category: Identifiable {
    let id: String
    let name: String
    let icon: String
    let filter: CategoryFilter
    
    enum CategoryFilter {
        case genre(String)
        case yearRange(Int, Int)
        case rating(ClosedRange<Double>)
        case status(WatchStatus)
    }
}

enum FilterCriteria: Codable {
    case genre(String)
    case genreNot(String)
    case rating(ClosedRange<Double>)
    case year(Int)
    case yearRange(Int, Int)
    case status(WatchStatus)
    case tag(String)
    case duration(ClosedRange<Int>)
    case titleContains(String)
    case watchCountAtLeast(Int)
    case recentlyAdded(Int)

    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    private enum ValueType: String, Codable {
        case genre
        case genreNot
        case rating
        case year
        case yearRange
        case status
        case tag
        case duration
        case titleContains
        case watchCountAtLeast
        case recentlyAdded
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ValueType.self, forKey: .type)

        switch type {
        case .genre:
            let value = try container.decode(String.self, forKey: .value)
            self = .genre(value)
        case .genreNot:
            let value = try container.decode(String.self, forKey: .value)
            self = .genreNot(value)
        case .rating:
            let value = try container.decode(String.self, forKey: .value)
            let bounds = value.split(separator: "-").compactMap { Double($0) }
            guard bounds.count == 2 else { throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid rating range")) }
            self = .rating(bounds[0]...bounds[1])
        case .year:
            let value = try container.decode(Int.self, forKey: .value)
            self = .year(value)
        case .yearRange:
            let value = try container.decode(String.self, forKey: .value)
            let years = value.split(separator: "-").compactMap { Int($0) }
            guard years.count == 2 else { throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid year range")) }
            self = .yearRange(years[0], years[1])
        case .status:
            let value = try container.decode(WatchStatus.self, forKey: .value)
            self = .status(value)
        case .tag:
            let value = try container.decode(String.self, forKey: .value)
            self = .tag(value)
        case .duration:
            let value = try container.decode(String.self, forKey: .value)
            let bounds = value.split(separator: "-").compactMap { Int($0) }
            guard bounds.count == 2 else { throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid duration range")) }
            self = .duration(Int(bounds[0])...Int(bounds[1]))
        case .titleContains:
            let value = try container.decode(String.self, forKey: .value)
            self = .titleContains(value)
        case .watchCountAtLeast:
            let value = try container.decode(Int.self, forKey: .value)
            self = .watchCountAtLeast(value)
        case .recentlyAdded:
            let value = try container.decode(Int.self, forKey: .value)
            self = .recentlyAdded(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .genre(let value):
            try container.encode(ValueType.genre, forKey: .type)
            try container.encode(value, forKey: .value)
        case .genreNot(let value):
            try container.encode(ValueType.genreNot, forKey: .type)
            try container.encode(value, forKey: .value)
        case .rating(let range):
            try container.encode(ValueType.rating, forKey: .type)
            let value = "\(range.lowerBound)-\(range.upperBound)"
            try container.encode(value, forKey: .value)
        case .year(let value):
            try container.encode(ValueType.year, forKey: .type)
            try container.encode(value, forKey: .value)
        case .yearRange(let start, let end):
            try container.encode(ValueType.yearRange, forKey: .type)
            let value = "\(start)-\(end)"
            try container.encode(value, forKey: .value)
        case .status(let value):
            try container.encode(ValueType.status, forKey: .type)
            try container.encode(value, forKey: .value)
        case .tag(let value):
            try container.encode(ValueType.tag, forKey: .type)
            try container.encode(value, forKey: .value)
        case .duration(let range):
            try container.encode(ValueType.duration, forKey: .type)
            let value = "\(range.lowerBound)-\(range.upperBound)"
            try container.encode(value, forKey: .value)
        case .titleContains(let value):
            try container.encode(ValueType.titleContains, forKey: .type)
            try container.encode(value, forKey: .value)
        case .watchCountAtLeast(let value):
            try container.encode(ValueType.watchCountAtLeast, forKey: .type)
            try container.encode(value, forKey: .value)
        case .recentlyAdded(let value):
            try container.encode(ValueType.recentlyAdded, forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
}
