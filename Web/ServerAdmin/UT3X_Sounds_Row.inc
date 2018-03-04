<tr class="<%evenodd%>">
  <form method="post" action="<%page.fulluri%>">
  <td><input type="text" name="soundmsg" value="<%ut3x.sounds.soundmsg%>" /></td>
  <td><input type="text" name="soundclassname" value="<%ut3x.sounds.soundclassname%>" size="70" /></td>
  <td><input type="text" name="bonlyadminusage" value="<%ut3x.sounds.bonlyadminusage%>" size="5" /></td>
  <td>
    <input name="numsound" value="<%ut3x.sounds.numsound%>" type="hidden">
	<button type="submit" name="action" value="save">Save</button>
    <button type="submit" name="action" value="delete" onclick="return confirm('Are you sure you want to delete this sound?');">Delete</button>
  </td>
  </form>
</tr>
