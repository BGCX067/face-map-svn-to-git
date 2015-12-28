package facemap;

import facemap.PMF;

import java.io.IOException;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.jdo.Transaction;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.Date;
import java.util.List;

/**
 * Servlet implementation class DeleteLandmarkServlet
 */
public class DeleteLandmarkServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public DeleteLandmarkServlet() {
        super();
        // TODO Auto-generated constructor stub
    }


	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		String userID = request.getParameter("userID");
		String landmarkName = request.getParameter("landmarkName");


		PersistenceManager pm = PMF.get().getPersistenceManager();
		String queryString = "SELECT FROM " + Landmark.class.getName() + " WHERE landmarkName == '"+ landmarkName.replace("'", "\\\'") +"' && userID == '"+ userID.replace("'", "\\\'") +"'";
		
		Query qr = pm.newQuery(queryString);
		List<Landmark> landmarks = (List<Landmark>) qr.execute();
		

		Transaction tx=pm.currentTransaction();
		try
		{
		    tx.begin();
		    
		    if(!landmarks.isEmpty()){
				for (Landmark lm : landmarks) 
				{
					pm.deletePersistent(lm);
				}
			}
		    
		    
		    tx.commit();
		}
		finally
		{
		    
		    pm.close();
		}
		
		
		response.sendRedirect("/Facemap/jsp/index.jsp");
	}

}
