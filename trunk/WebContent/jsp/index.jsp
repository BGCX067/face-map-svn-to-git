<%@ page import="java.util.List" %>
<%@ page import="java.util.ListIterator" %>
<%@ page import="java.util.Collections" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>

<%@ page import="facemap.PMF" %>
<%@ page import="facemap.Landmark" %>

<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:og="http://ogp.me/ns#"
      xmlns:fb="http://www.facebook.com/2008/fbml">


	<head>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<link rel="icon" href="../images/facemapicon.ico">
		<title>Favemap</title>
		<meta property="og:title" content="Favemap"/>
	    <meta property="og:type" content="facebook app"/>
	    <meta property="og:url" content="http://www.favemap.com"/>
	    <meta property="og:image" content="http://204.236.135.229/Facemap/images/facemapicon.ico"/>
	    <meta property="og:site_name" content="Favemap"/>
	    <meta property="fb:admins" content="683336267"/>
	    <meta property="fb:app_id" content="172466926106436"/>
	    <meta property="og:description"
	          content="Map your friends. Share important places with your friends"/>
		
		<meta name="keywords" content="map, favorite map, favemap, friends map, facebook, facemap, social map" />
		<meta name="description" content="" />
		
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
			src="http://www.google.com/jsapi?key=ABQIAAAA-yt2NvopHgpMPe6DUzQiVBRjF7pK8003IHvT3S-9Y-icuoA2whTn-xks3maFqsjWgMslF4NvA9wExQ"></script>
	
		
		<%-- GOOGLE MARKER MANAGER --%>
		<script src="http://gmaps-utility-library.googlecode.com/svn/trunk/markermanager/release/src/markermanager.js"></script>			
			
		<%-- Script containing map functionalities --%>
		<script type="text/javascript">
					
			google.load("maps", "2.x"); <%--load google map--%>
		
			var map = null;
			var markers = []; 
			var geocoder = null;
			var landmark = null;
			var mgr;
      
	        <%----------------------------------- Initialize Google Map -------------------------------------%>
			function initialize() {
	
				map = new google.maps.Map2(document.getElementById("mapcanvas"));
				map.enableGoogleBar();
				map.addControl(new GMapTypeControl());	
				<%--map.setUIToDefault();--%>
				
				var uiOptions = map.getDefaultUI();
			    uiOptions.controls.scalecontrol = true;
			    uiOptions.controls.largemapcontrol3d = true;
			    uiOptions.controls.maptypecontrol = true;
			  
			    <%-- Now set the map's UI with the tweaked options. --%>
			    map.setUI(uiOptions);
	
			    <%--map.addMapType(G_SATELLITE_3D_MAP);--%>
			    //var type = G_PHYSICAL_MAP;
			    var type =G_NORMAL_MAP;
			    map.setMapType(type);		
			
				var latlng = new google.maps.LatLng(37.4419, -100.1419);
				var location = "Showing default location for map.";
				
				<%-- get current user location --%>
				if (google.loader.ClientLocation) {
				  latlng = new google.maps.LatLng(google.loader.ClientLocation.latitude, google.loader.ClientLocation.longitude);
				  location = "Showing IP-based location: <b>" + getFormattedLocation() + "</b>";
				  markers.push(new GMarker(latlng, {title:"Your IP-Based Location."})); <%-- add marker to top of markers array --%>
				}
				
				initGMarkerManager();	
				
				<%-- initial markers setup --%>
				setupMarkers();
				
				<%-- map.setCenter(latlng, 13); --%>
				
				<%-- set center to BC --%>
				map.setCenter(new google.maps.LatLng(54.498871, -126.550713), 3);
				
				<%-- double click on map to show reverse geocoding addresses --%>
				GEvent.addListener(map, "dblclick", clicked);

				checkLoginStatus();
		
			}
		    
			<%------------------------------------ GMarker ---------------------------------------%>
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
	
	
			function placeMarker(landmark) {
				var qualify = 0;
				var i;
				
				if(FB_LOGGED_USER_ID == landmark.fbID){
					qualify=1;
				}
				for(i=0;i<friendsListSize;i++){
					if(friendsID[i] == landmark.fbID){
						qualify=1;
					}
				}
				
				if(qualify == 1){
					geocoder = new GClientGeocoder();
			
					if (geocoder) {
						geocoder.getLatLng(landmark.address, function(point) {
		
							if (!point) {
								//alert(landmark.address + " not found");
								setTimeout("placeMarker(landmark)",3000);
							} 
							else{	
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
								customIcon.image = 'http://graph.facebook.com/'+ landmark.fbID +'/picture'; 
								customIcon.iconSize =  new GSize(30,32); 
								markerOptions = { icon:customIcon, title:landmark.address };
								var marker = new GMarker(point, markerOptions );
												
								<%-- add marker to top of markers array --%>
								markers.push(marker); 
		
								<%-- on click / mouseover, show info --%>
								GEvent.addListener(marker,"click", function()
						        {
									var t = ('<img align="left" src="http://graph.facebook.com/'+ landmark.fbID + '/picture" style="padding-right:7px;padding-bottom:5px;"/>');
									
									t = t+  '<div class="infoHeader">'+landmark.userID+ '</div><div  class="info">';
							        t = t+ 'Name : ' + landmark.landmarkName +'<br/>';
							        t = t+ 'Category : ' + landmark.category +'<br/>';  
							        t = t+ 'Address : ' + landmark.address +'<br/>';
						            if(landmark.description != '')
							            t = t+ 'Description : ' + landmark.description +'<br/>';           
							        t = t+ 'Added on : ' + landmark.dateAdded +'<br/>';       
							        t = t+ '</div>';
							        
							        <%-- can only delete if it belongs to logged user--%>
							        if(FB_LOGGED_USER_ID == landmark.fbID){
								        t = t+ '<form id="delete_form" action="/Facemap/deleteLandmark"  method="post" style="display:inline;"/>'+
										'<input type ="hidden" name="userID" value= "'+landmark.userID+'">' +
										'<input type ="hidden" name="landmarkName" value= "'+landmark.landmarkName + '"/>' +
										'<input type ="image" alt="Delete Landmark" title="Delete Landmark" align="right" src="../images/trash_bin.gif" height="35" width="35"/>' + 
										'</form>';
							        }
							        
							        map.openInfoWindowHtml(point, t);
							        
							    	
		
						        });
								
								<%-- set marker on the map! --%>
								setupMarkers();
		
							}
						});
					}
				}
			}
			
			<%------------------------------------------- Geocoding ------------------------------------------------%>
			
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
	
			<%--------------------------------------- Reverse Geocoding --------------------------------------------%>
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
		
	
		<%---------------------------------------  Modal Add Form -------------------------------------------%>
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
		
		<%------------------------------------------ Slide Panel --------------------------------------------%>
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
				
				<%-- Switch buttons on click --%>
				$("#toggle a").click(function () {
					$("#toggle a").toggle();
				});		
			});
			
			
		</script>
		
		<%-- Facebook Social Plugin --%>
		<script src="http://connect.facebook.net/en_US/all.js#appId=172466926106436&amp;xfbml=1"></script>	
		
		<%---------------------------------------- Facebook AsyncInit ----------------------------------------%>
		<script type="text/javascript">
		
		      window.fbAsyncInit = function() {
		        FB.init({appId: '172466926106436', status: true, cookie: true,
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
   
		</script>
			
		<%------------------------------------- Facebook related functions -----------------------------------%>
		<script type="text/javascript">
		var FB_LOGGED_USER_NAME;
		var FB_LOGGED_USER_ID;
		var friendsID = [];
		var friendsListSize;
		var friendsLocation = [];

			function showGuestView() {
				$('.useronly').hide();
				$('.nonuseronly').show();
				$('.container').show();
			}
			
			function showUserView() {
				$('.nonuseronly').hide();
				$('.container').hide();
				$('.useronly').show();
				getLoggedUserInfo();
			}
			
			
			function checkLoginStatus() {
				showGuestView();
				FB.login(function(response) {
					  if (response.session) {
					    if (response.perms) {
					    	<%-- user is logged in and granted some permissions. --%>
					      <%-- perms is a comma separated list of granted permissions --%>
					      showUserView();
					    } else {
					      <%-- user is logged in, but did not grant any permissions--%>
					      showGuestView();
					    }
					  } else {
					    <%-- user is not logged in--%>
					    showGuestView();
					  }
					}, {perms:'user_location, user_hometown, friends_location, friends_hometown'});
			}
			
			function fbLogIn(){
				FB.login(function(response) {
					  if (response.session) {
					    if (response.perms) {
					      <%-- user is logged in and granted some permissions. --%>
					      <%-- perms is a comma separated list of granted permissions --%>
					      window.location.reload();
					    } else {
					      <%-- user is logged in, but did not grant any permissions --%>
					    }
					  } else {
					    <%-- user is not logged in --%>
					  }
					}, {perms:'user_location, user_hometown, friends_location, friends_hometown'});
			}
			
			
			function fbLogOut(){				
				FB.logout(function(response) {
					  <%-- user is now logged out --%>
					});
				showGuestView();	
			}
			
			function getLoggedUserInfo(){	
				FB.api('/me', function(response) {
					FB_LOGGED_USER_NAME = response.name;
					FB_LOGGED_USER_ID = response.id;
				});
				
				FB.api('/me/friends', function(response) {
	        		var friends = response.data;
	        		friendsListSize = friends.length;
	        		for (var i = 0; i < friends.length; i++) {
	        			var friend = response.data[i];
	        			friendsID.push(friend.id);
	        			//friendsLocation.push(friend.location.name);
	        			
	        		}
	        	});
			}
			
		   function friendList() {
			   
			   	alert(FB_LOGGED_USER_NAME);
	        	FB.api('/me/friends', function(response) {
	        		var divInfo = document.getElementById("divInfo");
	        		var friends = response.data;
	        		divInfo.innerHTML += '<h1 id="header">Friends</h1><ul>';
	        		for (var i = 0; i < friends.length; i++) {
	        			var friend = response.data[i];
	        			divInfo.innerHTML +=
	        				'<li><img src="http://graph.facebook.com/' + friend.id + '/picture"</img>'
	        				+ friend.id + ': ' + friends[i].name + '</li>';
	        			friendsID.push(friend.id);
	        		}
	        	
	        		FB.XFBML.parse(document.getElementById('divInfo'));
	        		divInfo.innerHTML += '</ul></div>';
	        	});
	        }
		   
			
		</script>	

	<script type="text/javascript"> 
		$(document).ready(function(){
		
		<%-- Larger thumbnail preview --%>
		
		$("ul.thumb li").hover(function() {
			$(this).css({'z-index' : '10'});
			$(this).find('img').addClass("hover").stop()
				.animate({
					marginTop: '-110px', 
					marginLeft: '-110px', 
					top: '50%', 
					left: '50%', 
					width: '174px', 
					height: '174px',
					padding: '20px' 
				}, 200);
			
			} , function() {
			$(this).css({'z-index' : '0'});
			$(this).find('img').removeClass("hover").stop()
				.animate({
					marginTop: '0', 
					marginLeft: '0',
					top: '0', 
					left: '0', 
					width: '100px', 
					height: '100px', 
					padding: '5px'
				}, 400);
		});
		
		<%-- Swap Image on Click --%>
			$("ul.thumb li a").click(function() {
				
				var mainImage = $(this).attr("href"); <%--Find Image Name --%>
				$("#main_view img").attr({ src: mainImage });
				return false;		
			});
		 
		});
	</script> 

		
	</head>


	<body>
		<%-- start header --%>
		<div id="header">
			<div id="menu">
				<ul>
					<li><a href="http://www.facebook.com/apps/application.php?id=172466926106436#!/apps/application.php?id=172466926106436&v=info" class="contimage" title="About Favemap">Favemap</a></li>
				</ul>
			</div>
		</div>
		<%-- end header --%>

		<%-- Panel --%>
		<div id="toppanel" class="useronly">
			<div id="panel">
				<div class="content clearfix">
					<span class="left">
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
					</span>
					
					<span class="left right">
					<form id="namefilter" onsubmit="return false;">
						Name: <input type="text" name="name" />
						<input type="image" src="../images/search_name.png" alt="Search" id="searchname" onClick="showAndClearField(this.form)" class="contimage" style="display:inline">  	
					</form>
					</span>	
					
					<span class="left right">
						<a href="http://twitter.com/share" class="twitter-share-button" data-url="http://www.favemap.com" data-text="Check this out!" data-count="none">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script>
						<script src="http://connect.facebook.net/en_US/all.js#xfbml=1"></script><fb:like href="www.favemap.com" show_faces="false" width="450" font="segoe ui"></fb:like>
					</span>	
				</div>
			</div>
		
			<%-- The tab on top --%>	
			<div class="tab">
				<ul class="login">
					<li class="left">&nbsp;</li>
					<li class="sep">|</li>
					<li id="toggle">
						<a id="open" class="open" href="#">Show Option</a>
						<a id="close" style="display: none;" class="close" href="#">Hide Option</a>			
					</li>
					<li class="right">&nbsp;</li>
				</ul> 
			</div> <%-- / top --%>
			
		</div> <%--panel --%>
		
	
		
	
		<script type="text/javascript">
		
		<%------------------------------------------- Start Loading Marker --------------------------------------%>
		
		
		var startLoadMarker = function(){
			
			if (friendsID[0] == undefined)
				setTimeout(startLoadMarker,500);
			else
				loadMarker();
			
		};
		
		startLoadMarker();

		function loadMarker(){
			
			document.getElementById("avatar").innerHTML += '<img src="http://graph.facebook.com/' + FB_LOGGED_USER_ID + '/picture">';
			
			<% 
			PersistenceManager pm = PMF.get().getPersistenceManager();
		  	Query qr = pm.newQuery(facemap.Landmark.class);
		  	List<Landmark> landmarks = (List<Landmark>) qr.execute();
		  	if(!landmarks.isEmpty()){
		  		for (Landmark lm : landmarks) 
		  		{
		  	%>	
					landmark = {'userID': "<%=lm.getUserID()%>", 'fbID': "<%=lm.getFbID()%>", 'landmarkName': "<%=lm.getLandmarkName()%>", 'address': "<%=lm.getAddress()%>", 'category': "<%=lm.getGeocode()%>", 'description': "<%=lm.getDescription()%>", 'dateAdded': "<%=lm.getDateFormat()%>" };
					placeMarker(landmark);			
		  			
			<%		
		  		}
		  	}
		  	%>
		}
	  	
		<%----------------------------------------- For filter by category ------------------------------------%>
	    $("select").change(function () {
	        clearMarkers();
	    	<% 
	      	if(!landmarks.isEmpty()){
	      		for (Landmark lm : landmarks) 
	      		{
	      	%>		
	      			var ctgy = '<%=lm.getGeocode()%>';
	      			
	      			if($("select option:selected").val() == "--select--"){
	      			}
	      			else if($("select option:selected").val() == "All"){
	      				landmark = {'userID': "<%=lm.getUserID()%>", 'fbID': "<%=lm.getFbID()%>", 'landmarkName': "<%=lm.getLandmarkName()%>", 'address': "<%=lm.getAddress()%>", 'category': "<%=lm.getGeocode()%>", 'description': "<%=lm.getDescription()%>", 'dateAdded': "<%=lm.getDateFormat()%>" };
	      				placeMarker(landmark);
	      			}
	      			else{
		      			if(ctgy == $("select option:selected").val()){
			      		    landmark = {'userID': "<%=lm.getUserID()%>", 'fbID': "<%=lm.getFbID()%>", 'landmarkName': "<%=lm.getLandmarkName()%>", 'address': "<%=lm.getAddress()%>", 'category': "<%=lm.getGeocode()%>", 'description': "<%=lm.getDescription()%>", 'dateAdded': "<%=lm.getDateFormat()%>" };
			      		    placeMarker(landmark);
		      			}
	      			}
	      		
	      	<%		
	      		}
	      	}
	      	
	      	%>

	        })
	        .trigger('change');
		    
		    
	    <%-------------------------------------------- For filter by name ----------------------------------------%>
		function showAndClearField(frm){
			
			String.prototype.equalTo = function( str )
			{
			  return this.toLowerCase() === str.toLowerCase();
			};

			  if (frm.name.value == "")
			      alert("Hey! You didn't enter anything!");
			  else{
					clearMarkers();
					<% 
					 	if(!landmarks.isEmpty()){
					 		for (Landmark lm : landmarks) 
					 		{
					 	%>		
					 			var UID = '<%=lm.getUserID()%>';
					
					 			if(frm.name.value.equalTo(UID)){
						  		    landmark = {'userID': "<%=lm.getUserID()%>", 'fbID': "<%=lm.getFbID()%>", 'landmarkName': "<%=lm.getLandmarkName()%>", 'address': "<%=lm.getAddress()%>", 'category': "<%=lm.getGeocode()%>", 'description': "<%=lm.getDescription()%>", 'dateAdded': "<%=lm.getDateFormat()%>" };
						  		    placeMarker(landmark);
					 			}
					 	<%		
					 		}
					 	}
					 	
					 	%>
					   frm.name.value = "";
			  }
			return false;
		}
		</script>
	
	
		<%-- service button --%>
		<div id="addLandmark" class="useronly"><a href="addLandmark.jsp" rel="facebox"><img src="../images/add_landmark_h.png" alt="image" class="contimage" border="0" /></a></div>
		
		<div id="avatar" class="useronly"></div>
		
		<div id="fbLogOut" class="useronly"> 
	      	<a href="#" class="contimage" onClick="fbLogOut()" style="text-decoration:none">Logout</a>
	    </div>
		<%--  end button --%>
			
		<div id="fblogin" class="nonuseronly">
			<fb:login-button v="3" size="large" onlogin="fbLogIn();">Login with Facebook</fb:login-button><fb:profile-pic uid="loggedinuser" size="small" linked="true" />
			<fb:name uid="loggedinuser" useyou="false" linked="true" capitalize="true" />
		</div>
		

		<%-- start map --%>
		<div id="mapcanvas" class="useronly"></div>
		<div id="clearfooter"></div>
		<%-- end map --%>
			
		<div class="container">
			<ul class="thumb">
				<li><a href="#"><img src="../images/thumb/thumb1.png" alt="" /></a></li>
				<li><a href="#"><img src="../images/thumb/thumb2.png" alt="" /></a></li>
				<li><a href="#"><img src="../images/thumb/thumb3.png" alt="" /></a></li>
				<li><a href="#"><img src="../images/thumb/thumb4.png" alt="" /></a></li>
				<li><a href="#"><img src="../images/thumb/thumb5.png" alt="" /></a></li>
				<li><a href="#"><img src="../images/thumb/thumb6.png" alt="" /></a></li>
				<li><a href="#"><img src="../images/thumb/thumb7.png" alt="" /></a></li>
				<li><a href="#"><img src="../images/thumb/thumb8.png" alt="" /></a></li>
				<li><a href="#"><img src="../images/thumb/thumb9.png" alt="" /></a></li>
			</ul>
		</div>	
			
			
		<%-- start footer --%>
		<div id="footer">
			<p id="legal">&copy;2010 Favemap. All Rights Reserved</p>
		</div>
		<%-- end footer --%>
		

	    <div id="fb-root"></div>  
		<div id="divInfo"></div>	
			
	</body>
	
</html>

