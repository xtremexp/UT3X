<tr class="<%evenodd%>">
  <td><%kickrule.label%> </td>
  <td><%kickrule.kickaction%></td>
  <td align="right"><%kickrule.banduration%></td>
  <td><input type="checkbox" <%kickrule.bnolog%> disabled/></td>
  <td align="right"><%kickrule.maxtimeforrepeat%></td>
  
  <td><%kickrule.kickactionrepeat%></td>
  <td align="right"><%kickrule.bandurationrepeat%></td>
  <td><input type="checkbox" <%kickrule.bnologrepeat%> disabled/></td>
  
  <td>
	<form method="post" action="<%page.fulluri%>">
	<input type="hidden" name="numKickRule" value="<%kickrule.numKickRule%>"/>
	<button type="submit" name="action" value="delete" onclick="return confirm('Are-you sure you want to delete this kick rule?');">DELETE</button>
	</form>
  </td>
</tr>
