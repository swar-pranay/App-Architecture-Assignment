# App-Architecture-Assignment
Another assignment to demonstrate the general architecture of an iOS app. Note: This project is no where near to an ideal project should be. It just demonstrates different layers of achitecture and their interworking.
The App is divided into UILayer, DataLayer, ServiceLayer and BusinessLayer 
- The UILayer with stroyboards, View and ViewController 
- The Datalayer persistence is done using Core Data.
- The Serive Layer is done using URLSession. This layer is resposible for all the external Network communication. 

Some Notes
- The UILayer:
a) The UI is done using Storyboard. That was the fast option considered. But the UI can be drawn in code as well using NSLayoutConstraints. 
b) I would have different storyboards for each scene or view and use storyboard references to link them. In the current implementation, I have everthing in one storyboard. Having multiple storybord make it easier to work in a team and avoid potention conflicts. 
c) Also, i am not making the call to the API until 250 millisecs are passesd since the user last typed, this avoid having to send multiple unnecesary call when the user is typing really fast.

- Data Layer:
a) For the puspose of this app having a core data for persistence is kind of an overkill, since there are no relationships to be managed. Other solution would have been using Archiving to store the objects into file store.
b) The Core data stack here is using just mainQueue MOC. For a bigger and more complex project, it would have privateQueue MOC, but thats not included in this current implementaiton. 
c) The Data Layer just consist of a single entity named Annotation with 4 attributes to store id, name, lattitude and longitude. 
d) Ideally the data layer will be responsible for creation and deletion and fetching of the objects from Core Data. Those are added in SearchResultsViewController which is not where all that logic should reside considering it is a UILayer which is leading to a Massive View Controler in the current implementation.
e) Also, in the current implemtation, the CoreDataStack is DI into the view controller as they are needed. 

- Service Layer:
a) Service layer has just has one NetworkManager Object in the current implementation. I deally I would have a more abstract Netowrk Client which just make the calls to the API using URLSession or Alamofire based on the provided URL Request and handles all the errors. And have a Seperate Service Objects for each API call which decorates and makes the URLRequest Objects based on that particular API requirement and send it to Network Client for make the call. But due to lack of time, I have made NetworkManager act as both, A NetworkClient and a Service Object. 

- Business Layer: 
a) This layer is resposible for interacting with rest of the layers. In the current implementation, the business layer make the API call and from the response received, parse the json into businessObjects (ACAnnotation in this case). I deally I would have another abstraction object which could be a Operation instance so, that the parsing happens in the background. 
b) The business layer that perfoms the function based on the business logic of the app. In the current scenario, it just has one Business Layer object (SearchResultsManager.swift) but in a bigger app, we would have more such objects.



TODO:
- Trim down LocationSearchViewController and SearchResultsViewController and give it much less resposibility.
- Have someone else act as a MKMapViewDelegate
- Have Extension in different file. This is also, useful when working in a team
- Have swift lint integrated so that the code formatting is taken care of.
- There is not proper error handling done in the current implementation, need to take care of possible errors more gracefully with several error enums
- I have not added many unit test, need to add more unit tests similar to what has been already implemented.
- Add Protocols
- AND MANY MORE...


