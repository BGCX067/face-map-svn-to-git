package org.facemap;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.*;

import java.util.*;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.facebook.api.*;

/**
 * Servlet implementation class for Servlet: MainPageServlet
 *
 *
 */
public class MainPageServlet extends AbstractFacebookServlet
      implements javax.servlet.Servlet {
   static final long serialVersionUID = 1L;
   
    /* (non-Java-doc)
	 * @see javax.servlet.http.HttpServlet#HttpServlet()
	 */
	public MainPageServlet() {
		super();
	}   	
	
	protected void doGet(
	         HttpServletRequest request,
	            HttpServletResponse response)
	         throws ServletException, IOException 
	   {
	      FacebookRestClient facebook =
	         getAuthenticatedFacebookClient(request, response);
	      
/*	      if ( facebook != null) {
	         if ( getFacebookInfo(request, facebook) ) {
	            request.getRequestDispatcher(
	               "../../WebContent/jsp/index2.jsp").forward(request, response);
	         }
	      }
*/
	      if ( facebook != null) {
	    	  if (getFacebookInfo(request, facebook) ) {
	    		  request.getRequestDispatcher(
	    				  "/Facemap/jsp/index.jsp").forward(request, response);
	    	  }
	      }

	   }

	   protected void doPost(
	         HttpServletRequest request,
	            HttpServletResponse response)
	         throws ServletException, IOException
	   {
	      doGet(request, response);
	   }
	   
	   /*
	    * This method obtains some basic Facebook profile
	    * information from the logged in user who is
	    * accessing our application in the current HTTP request.
	    */
	   private boolean getFacebookInfo(
	         HttpServletRequest request,
	         FacebookRestClient facebook) 
	   {
	      try {

	         long userID = facebook.users_getLoggedInUser();
	         Collection<Long> users = new ArrayList<Long>();
	         users.add(userID);

	         EnumSet<ProfileField> fields = EnumSet.of (
	            com.facebook.api.ProfileField.NAME,
	            com.facebook.api.ProfileField.PIC);

	         Document d = facebook.users_getInfo(users, fields);
	         String name = 
	            d.getElementsByTagName("name").item(0).getTextContent();
	         String picture = 
	            d.getElementsByTagName("pic").item(0).getTextContent();

	         request.setAttribute("uid", userID);
	         request.setAttribute("profile_name", name);
	         request.setAttribute("profile_picture_url", picture);

	      } catch (FacebookException e) {

	         HttpSession session = request.getSession();
	         session.setAttribute("facebookSession", null);
	         return false;

	      } catch (IOException e) {

	         e.printStackTrace();
	         return false;
	      }
	      return true;
	   }
	   
	   private boolean getFacebookFriends(
		         HttpServletRequest request,
		         FacebookRestClient facebook) {
		   
		   try {
			   Document doc = facebook.friends_get();
			   NodeList nodes = doc.getElementsByTagName("uid");
			   Collection<Integer> friends = new ArrayList<Integer>();
			   for (int i = 0; i < nodes.getLength(); i++) {
				   Node node = nodes.item(i);
				   String idText = node.getTextContent();
				   Integer id = Integer.valueOf(idText);
				   friends.add(id);
			   }
			   request.setAttribute("friends", friends);
		   } catch (FacebookException e) {

			   HttpSession session = request.getSession();
		       session.setAttribute("facebookSession", null);
		       return false;

		   } catch (IOException e) {

		       e.printStackTrace();
		       return false;
		   }
		   return true;
	   }
}