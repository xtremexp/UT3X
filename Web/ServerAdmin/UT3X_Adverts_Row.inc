<tr id="<%ut3x.adverts.idMsg%>" name="ligne" class="<%evenodd%>">
  <form method="post" action="<%page.fulluri%>">
  <td><input type="text" style="width: 500px;" value="<%ut3x.adverts.message%>" name="message" onchange="document.getElementById('save<%ut3x.adverts.idMsg%>').disabled=false;"/></td>
  <td><input type="text" id="DrawColor" name="DrawColor" class="colorwell" value="<%ut3x.adverts.drawcolor%>" onclick="document.getElementById('save<%ut3x.adverts.idMsg%>').disabled=false;"/></td>
  <td>
    <input type="hidden" id="PositionHidden-<%ut3x.adverts.idMsg%>" value="<%ut3x.adverts.Position%>"/>
	<select name="Position" id="Position-<%ut3x.adverts.idMsg%>" onchange="document.getElementById('save<%ut3x.adverts.idMsg%>').disabled=false;">
		<option value="0.000">0%-Top</option>
		<option value="0.1000">10%</option>
		<option value="0.2000">20%</option>
		<option value="0.3000">30%</option>
		<option value="0.4000">40%</option>
		<option value="0.5000">50%-Middle</option>
		<option value="0.6000">60%</option>
		<option value="0.7000">70%</option>
		<option value="0.8000">80%</option>
		<option value="0.8500">85%</option>
		<option value="0.9000">90%</option>
		<option value="1.0000">100%-Bottom</option>
	</select>
  </td>
  <td><input type="text" name="LifeTime" value="<%ut3x.adverts.LifeTime%>" onchange="document.getElementById('save<%ut3x.adverts.idMsg%>').disabled=false;"/></td>
  <td>
	<input type="hidden" id="FontSizeHidden-<%ut3x.adverts.idMsg%>" value="<%ut3x.adverts.FontSize%>"/>
	<select name="FontSize" id="FontSize-<%ut3x.adverts.idMsg%>" onchange="document.getElementById('save<%ut3x.adverts.idMsg%>').disabled=false;">
		<option value="0">Tiny</option>
		<option value="1">Small</option>
		<option value="2">Medium</option>
		<option value="3">Large</option>
	</select>
  </td>
  <td>&nbsp;</td>
  <td>
    <div>
    <input name="IDMsg" value="<%ut3x.adverts.idMsg%>" type="hidden">
    <button type="submit" name="action" value="delete" onclick="return confirm('Are you sure you want to delete this advert?');">Delete</button>
    </div>
  </td>
  <td>
	<input type="submit" id="save<%ut3x.adverts.idMsg%>" name="action" disabled="disabled" value="save"/>
  </td>
  </form>
</tr>
  <script>
		//setSelectedValue('Position-<%ut3x.adverts.idMsg%>', '<%ut3x.adverts.Position%>');
		//setSelectedValue('FontSize-<%ut3x.adverts.idMsg%>', '<%ut3x.adverts.FontSize%>');

  </script>
