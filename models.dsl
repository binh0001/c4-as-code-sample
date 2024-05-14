workspace {
    model {
        # People/Actors
        # <variable> = person <name> <description> <tag>
        publicUser = person "Public User" "An anonymous user of the bookstore" "User"
        authorizedUser = person "Authorized User" "A registered user of the bookstore, with personal account" "User"
        internalUser = person "Internal User" "An internal user of the bookstore" "User"

        # Software Systems
        # <variable> = softwareSystem <name> <description> <tag>
        bookstoreSystem = softwareSystem "iBookstore System" "Allows users to view about book, and administrate the book details" "Target System" {
            # Level 2: Containers
            # <variable> = container <name> <description> <technology> <tag>
            frontStoreApp = container "Front-store Application" "Provide all the bookstore functionalities to both public and authorized users" "JavaScript & ReactJS"
            backofficeApp = container "Back-office Application" "Provide all the bookstore administration functionalities to internal users" "JavaScript & ReactJS"
            searchWebApi = container "Search API" "Allows only authorized users searching books records via HTTPS API" "Go"
            adminWebApi = container "Admin Web API" "Allow ONLY internal users to manage books and purchases information using HTTPs" "Go" {
                # Level 3: Components
                # <variable> = component <name> <description> <technology> <tag>
                bookService = component "Book Service" "Allows administrating book details" "Go"
                authService = component "Authorizer" "Authorize internal users by using external Authorization System" "Go"
                bookEventPublisher = component "Book Events Publisher" "Publishes books-related events to Events Publisher" "Go"
            }
            publicWebApi = container "Public Web API" "Allows public users getting books information" "Go"
            searchDatabase = container "Search Database" "Stores searchable book information" "ElasticSearch" "Database"
            bookstoreDatabase = container "Bookstore Database" "Stores book details" "PostgreSQL" "Database"
            bookEventStream = container "Book Event System" "Handle the book published event and forward to the Book Event Consumer" "Apache Kafka 3.0"
            bookEventConsumer = container "Book Event Consumer" "Listening to domain events and write publisher to Search Database for updating" "Go"
            publisherRecurrentUpdater = container "Publisher Recurrent Updater" "Listening to external events from Publisher System, and update book information" "Go"
        }
        
        # External Software Systems
        authSystem = softwareSystem "Authorization System" "The external Identiy Provider Platform" "External System"
        publisherSystem = softwareSystem "Publisher System" "The 3rd party system of publishers that gives details about books published by them" "External System"
        shippingSystem = softwareSystem "Shipping System" "The 3rd party system to handle the book delivery" "External System"
        
        # Relationship between People and Software Systems
        # <variable> -> <variable> <description> <protocol>
        publicUser -> bookstoreSystem "View book information"
        authorizedUser -> bookstoreSystem "Search book with more details, administrate books and their details"
        internalUser -> bookstoreSystem "manage books and purchases information"
        bookstoreSystem -> authSystem "Register new user, and authorize user access"
        publisherSystem -> bookstoreSystem "Publish events for new book publication, and book information updates" {
            tags "Async Request"
        }
        bookstoreSystem -> shippingSystem "send book delivery information" {
            tags "Async Request"
        }

        # Relationship between Containers
        frontStoreApp -> publicWebApi "search book and place order" "JSON/HTTPS"
        frontStoreApp -> searchWebApi "search book and place order" "JSON/HTTPS"
        backofficeApp -> adminWebApi "administrate books and purchases" "JSON/HTTPS"
        publicUser -> frontStoreApp "use all the bookstore functionalities" "web page"
        publicUser -> publicWebApi "View book information" "JSON/HTTPS"
        publicWebApi -> searchDatabase "Retrieve book search data" "ODBC"
        authorizedUser -> searchWebApi "Search book with more details" "JSON/HTTPS"
        authorizedUser -> frontStoreApp "use all the bookstore functionalities" "web page"
        internalUser -> backofficeApp "use all the bookstore administration functionalities" "web page"
        searchWebApi -> authSystem "Authorize user" "JSON/HTTPS"
        searchWebApi -> searchDatabase "Retrieve book search data" "ODBC"
        authorizedUser -> adminWebApi "Administrate books and their details" "JSON/HTTPS"
        adminWebApi -> authSystem "Authorize user" "JSON/HTTPS"
        adminWebApi -> bookstoreDatabase "Reads/Write book detail data" "ODBC"
        adminWebApi -> bookEventStream "Publish book update events" {
            tags "Async Request"
        }
        bookEventStream -> bookEventConsumer "Consume book update events"
        bookEventConsumer -> searchDatabase "Write book search data" "ODBC"
        publisherRecurrentUpdater -> adminWebApi "API calls to update the data changes" "JSON/HTTPS"

        # Relationship between Containers and External System
        publisherSystem -> publisherRecurrentUpdater "Consume book publication update events" {
            tags "Async Request"
        }

        # Relationship between Components
        authorizedUser -> bookService "Administrate book details" "JSON/HTTPS"
        internalUser -> bookService "Administrate book details" "JSON/HTTPS"
        publisherRecurrentUpdater -> bookService "Makes API calls to" "JSON/HTTPS"
        bookService -> authService "Uses"
        bookService -> bookEventPublisher "Uses"

        # Relationship between Components and Other Containers
        authService -> authSystem "Authorize user permissions" "JSON/HTTPS"
        bookService -> bookstoreDatabase "Read/Write data" "ODBC"
        bookEventPublisher -> bookEventStream "Publish book update events"
    }

    views {
        # Level 1
        systemContext bookstoreSystem "SystemContext" {
            include *
            # default: tb,
            # support tb, bt, lr, rl
            autoLayout lr
        }
        # Level 2
        container bookstoreSystem "Containers" {
            include *
            autoLayout lr
        }
        # Level 3
        component adminWebApi "Components" {
            include *
            autoLayout lr
        }


        styles {
            # element <tag> {}
            element "Customer" {
                background #08427B
                color #ffffff
                fontSize 22
                shape Person
            }
            element "External System" {
                background #999999
                color #ffffff
            }
            relationship "Relationship" {
                dashed false
            }
            relationship "Async Request" {
                dashed true
            }
            element "Database" {
                shape Cylinder
            }
        }

        theme default
    }

}