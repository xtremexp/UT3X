<tr>
  <td>
	<form method="post" action="<%page.fulluri%>">
	<input type="hidden" name="banid" value="<%ut3x.ban.banId%>"/><!-- FOR UID, HASH BAN -->
	<input type="hidden" name="bannedPlayer" value="<%ut3x.ban.playerBanned%>"/>
	<input type="hidden" name="banType" value="<%ut3x.ban.banType%>"/>
	<button type="submit" name="action" value="delete" onclick="return confirm('Are you sure you want to delete this ban?');">Delete</button>
	</form>
  </td>
  <td><%ut3x.ban.admin%></td>
  <td><%ut3x.ban.banType%></td>
  <td class="right" onmouseover="tooltip.show(this)" onmouseout="tooltip.hide(this)" 
  title="<table><tr><td>Started:</td><td><%ut3x.ban.startTS%></td></tr><tr><td>Ends:</td><td><%ut3x.ban.endTS%></td></tr><tr><td>Ban Duration:</td><td><%ut3x.ban.duration%></td></tr></table>">
	<%ut3x.ban.remainingTime%>
  </td>
  <td nowrap><%ut3x.ban.reason%></td>
  <td><a href="/ServerAdmin/UT3X/UT3XPlayers?playerNameFilter=<%ut3x.ban.playerBanned%>&isNotInit=1"><%ut3x.ban.playerBanned%></a></td>
  <td><a href="/ServerAdmin/UT3X/UT3XPlayers?uniqueIdFilter=<%ut3x.ban.uniqueIdBanned%>&isNotInit=1"><%ut3x.ban.uniqueIdBanned%></a></td>
  <td><a href="/ServerAdmin/UT3X/UT3XPlayers?hashFilter=<%ut3x.ban.hashBanned%>&isNotInit=1"><%ut3x.ban.hashBanned%></a></td>
  <td nowrap>
	<%ut3x.computersBanned%>
  </td>
  <td><%ut3xplayer.ip%></td>
  
  <td><a href="/ServerAdmin/UT3X/UT3XPlayers?hashFilter=<%ut3x.ban.hashWhenBanned%>&isNotInit=1"><%ut3x.ban.hashWhenBanned%></a></td>
  <td nowrap><a href="/ServerAdmin/UT3X/UT3XPlayers?computerNameMD5Filter=<%ut3x.ban.compNameWhenBanned%>&isNotInit=1"><%ut3x.ban.compNameWhenBanned%></a></td>
  <td nowrap><a href="/ServerAdmin/UT3X/UT3XPlayers?ipFilter=<%ut3x.ban.ipWhenBanned%>&isNotInit=1"><%ut3x.ban.ipWhenBanned%></a></td>
</tr>
