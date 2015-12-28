package org.facemap;

import java.io.IOException;

import java.util.*;

import javax.servlet.ServletException;
import javax.servlet.http.*;

import org.w3c.dom.Document;

import com.facebook.api.*;

/**
 * Servlet implementation class for Servlet:
 * AbstractFacebookServlet
 *
 */
public class AbstractFacebookServlet
      extends javax.servlet.http.HttpServlet
      implements javax.servlet.Servlet
{
   protected static final String FB_APP_URL =
      "http://apps.facebook.com/myfacebookapp/";

   protected static final String FB_APP_ADD_URL =
      "http://www.facebook.com/add.php?api_key=";

   protected static final String FB_API_KEY =
      "1e2282160acf5925ee8d18434a10083a";

   private static final String FB_SECRET_KEY =
      "ad57f04566a464eb1ab3cef0895ceb1c";

   public AbstractFacebookServlet() {
      super();
   }

   /*
    * This method is used by all of the application's servlets
    * (or  web framework actions) to authenticate the app with
    * Facebook.
    */
   protected FacebookRestClient getAuthenticatedFacebookClient(
         HttpServletRequest request, HttpServletResponse response)
   {
      Facebook fb = new Facebook(request, response,
         FB_API_KEY, FB_SECRET_KEY);

      String next = request.getServletPath().substring(1);

      if (fb.requireLogin(next)) return null;

      return fb.getFacebookRestClient();
   }
}
