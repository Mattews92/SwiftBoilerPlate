# SwiftBoilerPlate
<p>

The <b>SwiftApp</b> project is a easy to build on boilerplate in <b>Swift4.x</b>
<br>
<h2> Modules of SwiftApp Boilerplate</h2>
<ol>
<li><b>AppDelegate</b></li>
<p>
The AppDelegate is customised to configure the app NavigationBar. An optional inactivity timeout mechanism is implemented which can be easily added to the project. The <b>InactivityTimer</b> class is a UIApplication subclass which manages the inactivity timeout employing the listeners in AppDelegate. Add the <b>main.swift</b> into the project target and comment the <b><i>@UIApplicationMain</i></b> in AppDelegate file to bring the InactivityTimer class into action.
</p>
<br>
<li><b>NetworkManager</b></li>
<p>
The  Network module manages the web services of the application. The <b><i>NetwortConstants</i></b> struct holds the webservice urls. The <b><i>AuthHandler</i></b> class handles the authorization token expiry with a retry mechanism implemented employing the retrier provided by Alamofire. The <b><i>Network manager</i></b> class initiates the web services through the <i>AuthHandler</i>. Webservices with session token are to be directed through AuthHandler and those without shall fire the method <b><i>fireWebService;</i></b>
</p>
<br>
</ol>

<h2>More frameworks</h2>
<ul>
<li> Interactive notifications <a href=https://github.com/Mattews92/InteractiveNotifications>here</a> </li>
<li> Slidermenu for Swift projects <a href=https://github.com/Mattews92/SliderMenu>here</a> </li>
</ul>
