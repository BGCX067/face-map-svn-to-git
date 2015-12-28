<%@ page import="java.util.List" %>
<%@ page import="java.util.ListIterator" %>
<%@ page import="java.util.Collections" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>

<%@ page import="facemap.PMF" %>
<%@ page import="facemap.Landmark" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
	<title>Add Landmark Form</title>
	<link rel="stylesheet" type="text/css" href="../css/modalform.css" />
	
	<%-- JQUERY  --%>
	<script type="text/javascript"
		src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
	<script type="text/javascript" src="../scripts/jquery.form.js"></script>
	
	<%-- FACEBOOK SOCIAL PLUGIN --%>
	<script src="http://connect.facebook.net/en_US/all.js#appId=111654302233770&amp;xfbml=1"></script>	
		
<%--	<script type="text/javascript">--%>
<%--		$(document).ready(function() {--%>
<%--			$('#submitform').ajaxForm({--%>
<%--				target: '#error',--%>
<%--				success: function() {--%>
<%--				$('#error').fadeIn('slow');--%>
<%--				}--%>
<%--			});--%>
<%--		});--%>
<%--	</script>--%>

	<%--  FORM VALIDATION  --%>
	<script type="text/javascript">
	
		function validate_required(field,alerttxt)
		{
	
			with (field)
			  {
				  
				  if (value==null||value=="")
				  {
						alert(alerttxt);
						return false;
				  }
				  else
						return true;
			  }
		}
		
		function validate_form_addLandmark(thisform)
		{
			with (thisform)
			{
				
		      if (validate_required(userID,"Please enter userID.") == false)
			  {
				  userID.focus();
				  return false;
			  }
		      
			  else if (validate_required(landmarkName,"Please enter a name.") == false)
			  {
				  landmarkName.focus();
				  return false;
			  }
			  else if (validate_required(address,"Please enter the address.") == false)
			  {
				  address.focus();
				  return false;
			  }
			  submit.value = "Click to confirm";			 
			}
			
			return true;
		}
		
		
		<%-- GET FB USER INFO --%>
		function getLoggedUserInfos(){	
			FB.api('/me', function(response) {
				FB_LOGGED_USER_NAME = response.name;
				FB_LOGGED_USER_ID = response.id;
				});
			
			document.getElementById("hiddenID").value = FB_LOGGED_USER_NAME;
			document.getElementById("hiddenFBID").value = FB_LOGGED_USER_ID;
		}
		
		var startLoad = function(){
			
			getLoggedUserInfos();
			if (FB_LOGGED_USER_NAME == undefined)
				setTimeout(startLoad,500);		
		};
		
		
		window.onload=startLoad();
	</script>
	
	</head>
	<body>
		<h2 id="modalh2">Add New Landmark</h2>
		<div id="modalform">
			<div id="formleft">
			
				<form id="submitform" action="/Facemap/addLandmark" onSubmit="return validate_form_addLandmark(this)" method="post">
				
					<input type="hidden" name= "userID" id="hiddenID">
					
					<input type="hidden" name= "fbID" id="hiddenFBID">
						
					<fieldset><legend>Landmark Name</legend> <input type="text"
						name="landmarkName" size="30" /></fieldset>
					
					<fieldset><legend>Address</legend> <input type="text"
						name="address" size="40" /></fieldset>
					<fieldset><legend>Category</legend>
					<select name="category">
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
					</select></fieldset>
					<fieldset><legend>Description</legend> <textarea rows="5"
						cols="40" name="description"></textarea></fieldset>
					
					<fieldset><input type="submit" id ="submit" value="Add Landmark" class="button" /></fieldset>
				</form>
			</div>
		
			<div id="error"></div>
			<div class="clear"></div>
		</div>
		
		 <%-- Checks for duplicate landmark name and validate address --%>
        <script> 

    		 var found = new Boolean();
    	
			 $("#submitform").submit(function() {	 
				 
				<%--Check for duplicate landmark name entered by the same user--%>
			    <% 
				PersistenceManager pm = PMF.get().getPersistenceManager();
			
				Query qr = pm.newQuery(facemap.Landmark.class);
				List<Landmark> landmarks = (List<Landmark>) qr.execute();
				if(!landmarks.isEmpty()){
					for (Landmark lm : landmarks) 
					{
						
				%>		
					if (($("input[name=userID]").val() == "<%= lm.getUserID()%>") && ($("input[name=landmarkName]").val() == "<%= lm.getLandmarkName()%>") ) { 
						alert("Similar landmark name already exists. Please choose another name.");
						return false;
					}		
		
				<%		
					}
				}
				pm.close();
				%>
				
				<%--Check if address can be found by geocoder--%>
				gc = new GClientGeocoder();
				
				if (gc) {
					
					if ($("input[name=address]").val() != ''){
						gc.getLatLng($("input[name=address]").val(), function(point) {
							if (!point) {
								alert("Address: " + $("input[name=address]").val() + " cannot be found.");
								found = false;
							}
							else{
								found = true;
							}
								
						});
					}
				}
				
				
				if (found == false)
					return false;
				else{
					$('input[type=submit]', this).attr('disabled', 'disabled');
					return true;
					 
				}
			 });
				
			 
	   </script>
	   
		
	</body>
</html>