<%@ page import="java.util.List" %>
<%@ page import="java.util.ListIterator" %>
<%@ page import="java.util.Collections" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>

<%@ page import="facemap.PMF" %>
<%@ page import="facemap.Landmark" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"
	  xmlns:fb="http://www.facebook.com/2008/fbml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title>Facemap</title>
	
	<%-- CSS --%>
	<link href="../css/default.css" rel="stylesheet" type="text/css" />
	<link href="../css/facebox.css" rel="stylesheet" type="text/css" />
	<link href="../css/modalform.css" rel="stylesheet" type="text/css" />
	<link href="../css/slide.css" rel="stylesheet" type="text/css" />

	<%-- JQUERY  --%>
	<script type="text/javascript"
		src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
	<script type="text/javascript" src="../scripts/jquery.form.js"></script>

	<%-- FACEBOX --%>
	<script type="text/javascript" src="../scripts/facebox.js"></script>

	<%-- GOOGLE MAP API --%>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Google Maps JavaScript API</title>
	<script type="text/javascript"
		src="http://www.google.com/jsapi?key=ABQIAAAAwJ_0JBiqcb596n2gQj1OthSEmb1UALpcbEWFJrr4JU7gn-RrUhS8Xc2LxNegdtkoA8acc_8rnF6EQw"></script>

	<%-- GOOGLE MARKER MANAGER --%>
	<script
		src="http://gmaps-utility-library.googlecode.com/svn/trunk/markermanager/release/src/markermanager.js"></script>

	<%-- Show logged in/guest views --%>
	<script type="text/javascript">
		function showGuestView() {
			if (document.getElementById) { // DOM3 = IE5, NS6
				document.getElementById('toppanel').style.visibility = 'hidden';
			} else {
				if (document.layers) { // Netscape 4
					document.toppanel.visibility = 'hidden';
				} else { // IE 4
					document.all.toppanel.style.visibility = 'hidden';
				}
			}
		}
		
		function showUserView() {
			if (document.getElementById) { // DOM3 = IE5, NS6
				document.getElementById('toppanel').style.visibility = 'visible';
			} else {
				if (document.layers) { // Netscape 4
					document.toppanel.visibility = 'visible';
				} else { // IE 4
					document.all.toppanel.style.visibility = 'visible';
				}
			}
		}
		
		function selectView(response) {
			if (response.session) {
				// user is logged in
				showUserView();
			} else {
				// user is not logged in
				showGuestView();
			}
		}
		
		function checkLoginStatus() {
			if (FB.getSession() != null) {
				// user is logged in
				showUserView();
			} else {
				// user is not logged in
				showGuestView();
			}
		}
		
//		function listFriends() {
//			var friends = FB.Data.query(
//				"SELECT uid1 FROM friend WHERE uid1={0}", FB.getSession().uid);
//			FB.Data.waitOn([friends], function(args) {
//				alert(friends.join("\n"));
//			});
			
//		}
				
      	window.onload=checkLoginStatus;
	</script>

	<%-- script containing map functionalities --%>
	<script type="text/javascript">
				
		google.load("maps", "2.x"); <%--load google map--%>
	
		var map = null;
		var markers = []; 
		var geocoder = null;
		var landmark = null;
		var mgr;
        
        <%---------------------------------- Initialize -------------------------------------%>
		function initialize() {

			map = new google.maps.Map2(document.getElementById("mapcanvas"));
			map.enableGoogleBar();
			map.addControl(new GMapTypeControl());	
			map.setUIToDefault();
		
			var latlng = new google.maps.LatLng(37.4419, -100.1419);
			var location = "Showing default location for map.";
			
			<%-- get current user location --%>
			if (google.loader.ClientLocation) {
			  latlng = new google.maps.LatLng(google.loader.ClientLocation.latitude, google.loader.ClientLocation.longitude);
			  location = "Showing IP-based location: <b>" + getFormattedLocation() + "</b>";
			  markers.push(new GMarker(latlng, {title:"You're here."})); <%-- add marker to top of markers array --%>
			}
			
			initGMarkerManager();	
			
			<%-- initial markers setup --%>
			setupMarkers();
			
			<%-- map.setCenter(latlng, 13); --%>
			
			<%-- set center to BC --%>
			map.setCenter(new google.maps.LatLng(54.498871, -126.550713), 5);
			
			<%-- double click on map to show reverse geocoding addresses --%>
			GEvent.addListener(map, "dblclick", clicked);

			
		}
	    
		<%------------------------------------GMarker---------------------------------------%>
		function getFormattedLocation() {
			if (google.loader.ClientLocation.address.country_code == "US" &&
			  google.loader.ClientLocation.address.region) {
			  return google.loader.ClientLocation.address.city + ", " 
				  + google.loader.ClientLocation.address.region.toUpperCase();
			} else {
			  return  google.loader.ClientLocation.address.city + ", "
				  + google.loader.ClientLocation.address.country_code;
			}
		}
		function setupMarkers(){
			 <%-- mgr = new GMarkerManager(map); --%>		        
		     mgr.addMarkers(markers.reverse(),0,17);
			 mgr.refresh();
		}
		
		function clearMarkers() {
			markers = [];
			map.clearOverlays(); 
			initGMarkerManager();
			  
		}
		
		function initGMarkerManager(){ 
			mgr = new GMarkerManager(map); 
		} 

		
		<%------------------------------------ Geocoding -------------------------------------%>
		
		<%-- parse point --%>
		function getLatLng (point) {
		     var matchll = /\(([-.\d]*), ([-.\d]*)/.exec( point );
		      if ( matchll ) {
		       var lat = parseFloat( matchll[1] );
		       var lon = parseFloat( matchll[2] );
		       lat = lat.toFixed(6);
		       lon = lon.toFixed(6);

		      } else {
		       var message = "<b>Error extracting info from</b>:" + point + "";
		       var messagRoboGEO = message;
		      }

		     return new GLatLng(lat, lon);
		 }

		function placeMarker(landmark) {
			
			geocoder = new GClientGeocoder();
	
			if (geocoder) {
				geocoder.getLatLng(landmark.address, function(point) {

					if (!point) {
						alert(landmark.address + " not found");
					} else {
						
						<%-- parse point --%>
						var latLng = getLatLng(point);
						
						<%-- update correct address name from point by reverse geocoding --%>
						if (latLng) {
					        geocoder.getLocations(latLng, function(addresses) {
					          if(addresses.Status.code != 200) {
					            alert("reverse geocoder failed to find an address for " + latlng.toUrlValue());
					          }
					          else {
					            address = addresses.Placemark[0];
					            landmark.address = address.address;
					          }
					        });
					    }							
						
						<%-- custom icon for gmarker --%>
						var customIcon = new GIcon(G_DEFAULT_ICON);
						customIcon.image = '../images/face.png'; 
						customIcon.iconSize =  new GSize(30,32); 
						markerOptions = { icon:customIcon, title:landmark.address };
						var marker = new GMarker(point, markerOptions );
										
						<%-- add marker to top of markers array --%>
						markers.push(marker); 

						<%-- on click, show info --%>
						GEvent.addListener(marker,"click", function()
				        {
							var t = ('<img align="left" src="../images/face.png" style="padding-right:7px;padding-bottom:5px;"/>');
							
					        t = t+  '<div class="infoHeader">'+landmark.userID+ '</div><div  class="info">';
					        t = t+ 'Name : ' + landmark.landmarkName +'<br/>';
					        t = t+ 'Category : ' + landmark.category +'<br/>';  
					        t = t+ 'Address : ' + landmark.address +'<br/>';
				            if(landmark.description != '')
					            t = t+ 'Description : ' + landmark.description +'<br/>';           
					        t = t+ 'Added on : ' + landmark.dateAdded +'<br/>';       
					        t = t+ '</div>';
					        
					        t = t+ '<form id="delete_form" action="/Facemap/deleteLandmark"  method="post" style="display:inline;"/>'+
							'<input type ="hidden" name="userID" value= "'+landmark.userID+'">' +
							'<input type ="hidden" name="landmarkName" value= "'+landmark.landmarkName + '"/>' +
							'<input type ="image" alt="Delete Landmark" title="Delete Landmark" align="right" src="../images/trash_bin.gif" height="35" width="35"/>' + 
							'</form>';
					        map.openInfoWindowHtml(point, t);
				        });
						
						<%-- set marker on the map! --%>
						setupMarkers();

					}
				});
			}
		}
		
		

		<%--------------------------------------- Reverse Geocoding -----------------------------------------------%>
		function clicked(overlay, latlng) {
		      if (latlng) {
	    	  <%-- Sends a request to Google servers to geocode the specified address. If the address was successfully located, --%>
	    	  <%-- the user-specified callback function is invoked with a GLatLng point. Otherwise, the callback function is given a null point. --%> 
	    	  <%-- Incase of ambiguous addresses, only the point for the best match is passed to the callback function. --%>
		        geocoder.getLocations(latlng, function(addresses) {
		          if(addresses.Status.code != 200) {
		            alert("reverse geocoder failed to find an address for " + latlng.toUrlValue());
		          }
		          else {
		            address = addresses.Placemark[0];
		            var myHtml = address.address;
		            map.openInfoWindow(latlng, myHtml);
		          }
		        });
		      }
		}

	
		function test(){
			alert("test");
		}
		
		
		google.setOnLoadCallback(initialize);	  
	</script>


	<%--  MODAL ADD FORM --%>
	<script type="text/javascript">
		$(document).ready(function(){
			 $(".contimage").hover(function() {
					$(this).animate({
						opacity:1
					},200);
				}, function() {
					$(this).animate({
						opacity:0.8
					},200);
			});
				$('#submitform').ajaxForm({
					target: '#error',
					success: function() {
					$('#error').fadeIn('slow');
					}
			});
		$('a[rel*=facebox]').facebox();
	}); 
	</script>

	<%-- Slide Panel --%>
	<script type="text/javascript">
		$(document).ready(function() {
		
		<%-- Expand Panel --%>
		$("#open").click(function(){
			$("div#panel").slideDown("slow");
		
		});	
		
		<%-- Collapse Panel --%>
		$("#close").click(function(){
			$("div#panel").slideUp("slow");	
		});		
		
		<%-- Switch buttons from "Log In | Register" to "Close Panel" on click --%>
		$("#toggle a").click(function () {
			$("#toggle a").toggle();
		});		
			
	});
	</script>
</head>


<body>
	<%-- start header --%>
	<div id="header">
		<div id="menu">
		<ul>
			<li><a href="#">Facemap</a></li>
			<li class="left"><fb:login-button></fb:login-button></li>
			<li><input type="button" value="Hide" onclick="showGuestView();"></li>
			<li><input type="button" value="Show" onclick="showUserView();"></li>
		</ul>
		</div>
	</div>
	<%-- end header --%>
	
	<%-- Panel --%>
	<div id="toppanel">
		<div id="panel">
			<div class="content clearfix">
				<div class="left">
					Category: <select id="categoryfilter" autocomplete="off" >
								  <option >--select--</option>
					              <option select="selected">All</option>
								  <option>Home</option>
								  <option>Work</option>
								  <option>School</option>
								  <option>Travel</option>
								  <option>Event</option>
								  <option>Activity</option>
								  <option>Shop</option>
								  <option>Restaurant</option>
								  <option>Bar</option>
								  <option>Hotel</option>
								  <option>Special</option>
							</select>				
			</div>
		</div>
	
		<%-- The tab on top --%>	
		<div class="tab">
			<ul class="login">
				<li class="sep">|</li>
				<li id="toggle">
					<a id="open" class="open" href="#">Filter Panel</a>
					<a id="close" style="display: none;" class="close" href="#">Close Panel</a>			
				</li>
				<li class="right">&nbsp;</li>
			</ul> 
		</div>
		<%-- /top --%>
	</div>
	<%-- /panel --%>
	

	
	
	
	
	<%-- service button --%>
	<div id="addLandmark"><a href="addLandmark.jsp" rel="facebox"><img src="../images/add_landmark_h.png" alt="image" class="contimage" border="0" /></a></div>
	<%--  end button --%>
	
	<%-- start map --%>
	<div id="mapcanvas"></div>
	<div id="clearfooter"></div>
	<%-- end map --%>
	
	<%-- start footer --%>
	<div id="footer">
		<p id="legal">&copy;2010 Facemap. All Rights Reserved</p>
	</div>
	<%-- end footer --%>	

	<div id="fb-root"></div>
	<script>
      window.fbAsyncInit = function() {
        FB.init({appId: '111654302233770', status: true, cookie: true,
                 xfbml: true});
      };
      (function() {
        var e = document.createElement('script');
        e.type = 'text/javascript';
        e.src = document.location.protocol +
          '//connect.facebook.net/en_US/all.js';
        e.async = true;
        document.getElementById('fb-root').appendChild(e);
      }());
      
      function friendList() {
      	FB.api('/me/friends', function(response) {
      		var divInfo = document.getElementById("divInfo");
      		var friends = response.data;
      		divInfo.innerHTML += '<h1 id="header">Friends</h1><ul>';
      		for (var i = 0; i < friends.length; i++) {
      			var friend = response.data[i];
      			divInfo.innerHTML +=
      				'<li><fb:profile-pic uid="' + friend.id + '" width="50" height="50" />'
      				+ friend.id + ': ' + friends[i].name + '</li>';
      		}
      		FB.XFBML.parse(document.getElementById('divInfo'));
//      		divInfo.innerHTML += body;
      		divInfo.innerHTML += '</ul></div>';
      	});
      }
    </script>
    <input type="button" value="List Friends" onclick="friendList(); return false;">
    <div id="divInfo"></div>
	<div>
		<script>
			var friends = ${friends};
			document.write(friends.join("|"));
		</script>
	</div>
    			
</body>
</html>