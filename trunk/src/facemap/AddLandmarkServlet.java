package facemap;

import facemap.PMF;

import java.io.IOException;

import javax.jdo.PersistenceManager;
import javax.jdo.Transaction;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.Date;


/**
 * Servlet implementation class AddLandmarkServlet
 */
public class AddLandmarkServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AddLandmarkServlet() {
        super();
        // TODO Auto-generated constructor stub
    }


	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		String userID = request.getParameter("userID");
		String fbID = request.getParameter("fbID");
		String landmarkName = request.getParameter("landmarkName");
		String address = request.getParameter("address");
		String category = request.getParameter("category");
		String description = request.getParameter("description");
		Date date = new Date();
//		SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
//		String dateString = formatter.format(date);//test date
		
//		String awsAccessId = "AKIAJC64UGO4B7MPUEUQ";
//		String awsSecretKey = "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";

		PersistenceManager pm = PMF.get().getPersistenceManager();
		
		Transaction tx=pm.currentTransaction();
		try
		{
		    tx.begin();
		    Landmark landmark = new Landmark(userID, fbID, landmarkName, address, category, description, date);
		    pm.makePersistent(landmark);
		    tx.commit();
		}
		finally
		{
		    if (tx.isActive())
		    {
		        tx.rollback();
		    }
		    pm.close();
		}
		
		
		response.sendRedirect("/Facemap/jsp/index.jsp");
	}

}
