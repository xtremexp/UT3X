<tr class="<%evenodd%>">
  <form method="post" action="<%page.fulluri%>">
  <td><input type="text" name="smileyText" value="<%ut3x.smileys.smileyText%>" /></td>
  <td><input type="text" name="smileyTexture" value="<%ut3x.smileys.smileyTexture%>" size="70" /></td>
  <td><input type="text" name="bonlyadminusage" value="<%ut3x.smileys.bonlyadminusage%>" size="5" /></td>
  <td>
    <input name="numSmiley" value="<%ut3x.smileys.numSmiley%>" type="hidden">
	<button type="submit" name="action" value="save">Save</button>
    <button type="submit" name="action" value="delete" onclick="return confirm('Are you sure you want to delete this smiley?');">Delete</button>
  </td>
  </form>
</tr>
