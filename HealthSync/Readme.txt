HealthSync

Description : 

Healthsync is iPhone mobile application to sync users health data with multiple sources. Currently we supports only step count where user can sync their step in between multiple sources as follows.

1. HealthSync StepCounter to Fitbit
2. Fitbit to HealthKit
3. Healthkit to Fitbit

It also include features like user's can view their Fitbit profile once they have logged in to the application. User can also view their past synced logs in table format. 

Future enhancement: Addition of Height and Weight as health data.

Team members:

1. Girish Chaudhari (817375231)
2. Simranpreet singh ()

Requirements:

1.Fitbit account

Third party library used:

1.OAuthSwift -> 0.4.6 (OAuth 2.0 implementation for fitbit api)
github link - > https://github.com/OAuthSwift/OAuthSwift

2.Alamofire -> 3.0 (Fitbit restapi handling)
github link - >https://github.com/Alamofire/Alamofire

Known issues:

Sometime app crashes on click of Health&Fitbit sync button due to refresh token expiration scenario.We tried to handle this in best possible way. (Not always reproducible)
