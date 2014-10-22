PingAppProto
============

Ping App Prototype

Initial requirements for the project:

*UIView with map
*UIButton with start ping, stop ping
*Set of users, Me Kaz Clarke, Johnny Jeremy
*Display all users on map that are sharing location
*Zoom map to scale of distance between users
*Simple web service implementation (using Parse: https://www.parse.com)
*Pick user we are by sliding a disk pick 1-5

============

Code reuse -

Used a tutorial that explained how to present a circular control that allows the user 
to select a value (in the app's case, a number 1 - 4).

URL to tutorial here: http://www.raywenderlich.com/9864/how-to-create-a-rotating-wheel-control-with-uikit

Using the Parse and Bolts frameworks, downloaded from the Parse web site: https://www.parse.com

============

App consists of two view controllers:
  1. Registration Controller
  2. Map Controller
  
The Registration controller requires the user to enter First Name, Last Name, and Email Address. This 
information is used to create a user record via a Parse framework method call.  The successful record 
creation provides the app with the 'objectId' of the record, uniquely identifying the current app user.

The Map Controller (after prompting for authorization to use the location of the user) displays the user's
current location, as well as the locations of the other users who have tapped the 'Start Ping' button in the
toolbar in the bottom left.  If the user taps the button with the 'up' arrow just above the toolbar, this
presents the circular selection control in the center of the screen. The user can drag the wheel to change
the selection. When the user taps 'OK' the control is dismissed, and the corresponding user (just a basic
'object at index' method call against an array) is retrieved, the distance between the selected user and the
current user is calculated and the map is zoomed in or out accordingly.

App Icons and all images, with the exception of the globe (in the app icon) and the up arrow (seen in the map view)
were generated using Pixelmator or a Mac App called 'Art Text 2'.

Issues to revisit -
  1. Localization - given the global reach of an app like this, texts presented to the user should be provided in
  the standard 9 languages, when possible.
  2. User selection control - during testing, it was noticed that the scrolling of the wheel wasn't as smooth as 
  it should be. Also, if the touch was interrupted, or cancelled (the finger used to scroll strayed outside the defined
  area) the wheel stopped without moving on to the closest selection.  Also, a more intuitive use of this could be
  implemented.
  3. Custom Map Pin objects - images could be used in place of pins (the first thing that comes to mind are board
  game pieces...Monopoly).
  4. Custom Map Annotation Views - instead of just showing the user name and their status (online, idle/inactive or
  offline), we could include a way for the user to upload a photo that could be shown in the annotation view.
  5. Registration screen improvements - went with the basics for this project - should look at some sort of formal logo
  or background image for the reg screen, as well as custom text fields.
