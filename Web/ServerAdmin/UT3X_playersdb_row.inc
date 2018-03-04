<tr class="<%evenodd%>">
  <td>
	<%numLine%>
	<input type="radio" name="playername" value="<%ut3xplayer.name%>">
  </td>
  <td><%ut3xplayer.clantags%></td>
  <!--
  <td><a href="<%page.fulluri%>?findClones=<%ut3xplayer.uniqueid%>&isNotInit=1"><%ut3xplayer.name%></a></td>
  -->
  <td><%ut3xplayer.name%></td>
  <td><a href="<%page.fulluri%>?uniqueIdFilter=<%ut3xplayer.uniqueid%>&isNotInit=1"><%ut3xplayer.uniqueid%></a></td>
  <td><%ut3xplayer.friends%></td>
  <td><%ut3xplayer.hashes%></td>
  <td align="right"><%ut3xplayer.comphashes%></td>
  <td align="right"><%ut3xplayer.deltatime%></td>
  <td align="right"><%ut3xplayer.ips%></td>
  <td><%ut3xplayer.ipranges%></td>
  <td>
	<%ut3xplayer.ip2c%>
  </td>
  <td onmouseover="tooltip.show(this)" onmouseout="tooltip.hide(this)" 
	title="First Prelogin:<%ut3xplayer.firstprelogin%><br>
	Last Prelogin:<%ut3xplayer.lastprelogin%><br>
	First Login:<%ut3xplayer.firstlogin%><br>
	Last Login:<%ut3xplayer.lastlogin%><br>
	Last Logout:<%ut3xplayer.lastlogout%>" >
	SEE
  </td>
</tr>
