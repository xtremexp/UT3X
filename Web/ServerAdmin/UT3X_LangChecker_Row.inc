<tr class="<%evenodd%>">
  <form method="post" action="<%page.fulluri%>">
  <td><input type="text" name="word" value="<%word%>" /></td>
  <td><input type="text" name="weight" value="<%weight%>" size="10" style="text-align: right;" /></td>
   <td><%LG%></td>
  <td>
    <input name="numBadWord" value="<%numBadWord%>" type="hidden">
	<button type="submit" name="action" value="save">Save</button>
    <button type="submit" name="action" value="delete" onclick="return confirm('Are you sure you want to delete this bad word?');">Delete</button>
  </td>
  </form>
</tr>
