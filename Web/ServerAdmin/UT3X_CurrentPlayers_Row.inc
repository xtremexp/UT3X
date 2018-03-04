<tr>
	<td style="background: <%player.teamcolor%>; color: <%player.teamcolor%>;"><%player.teamid%>&#160;</td>
	<td><a href="/ServerAdmin/UT3X/UT3XPlayers?clanTagFilter=<%ut3x.currentplayer.clantag%>&isNotInit=1"><%ut3x.currentplayer.clantag%></a></td>
	<td><a href="/ServerAdmin/UT3X/UT3XPlayers?playerNameFilter=<%ut3x.currentplayer.name%>&isNotInit=1"><%ut3x.currentplayer.name%></a></td>
	<td class="right <%cssclassping%>"><%ut3x.currentplayer.ping%></td>
	<td class="right <%cssclasspacketloss%>" onmouseover="tooltip.show(this)" onmouseout="tooltip.hide(this)" title="Packet Loss. If equals zero means stable connection else bad connectivity">
		<%ut3x.currentplayer.packetloss%>
	</td>
	<td class="right">
		<a href="/ServerAdmin/UT3X/UT3XPlayers?ipFilter=<%ut3x.currentplayer.ip%>&isNotInit=1" onmouseover="tooltip.show(this)" onmouseout="tooltip.hide(this)" title="Search players with same IP">
		<%ut3x.currentplayer.ip%></a>
	</td>
	<td class="right">
		<a href="/ServerAdmin/UT3X/UT3XPlayers?computerNameMD5Filter=<%ut3x.currentplayer.computerNameMD5%>&isNotInit=1" onmouseover="tooltip.show(this)" onmouseout="tooltip.hide(this)" title="Search players with same computer name">
		<%ut3x.currentplayer.computerNameMD5%></a>
	</td>
	
	<td onmouseover="tooltip.show(this)" onmouseout="tooltip.hide(this)" title="<%ut3x.currentplayer.countryname%>">
		<a href="/ServerAdmin/UT3X/UT3XPlayers?countryFilter=<%ut3x.currentplayer.country%>&isNotInit=1" onmouseover="tooltip.show(this)" onmouseout="tooltip.hide(this)" title="Search players with same country">
		<%ut3x.currentplayer.country%></a>
	</td>
	<td>
		<a href="/ServerAdmin/UT3X/UT3XPlayers?uniqueIdFilter=<%ut3x.currentplayer.uniqueid%>&isNotInit=1" onmouseover="tooltip.show(this)" onmouseout="tooltip.hide(this)" title="Search players with same ID"><%ut3x.currentplayer.uniqueid%></a>
	</td>
	<td>
		<a href="/ServerAdmin/UT3X/UT3XPlayers?hashFilter=<%ut3x.currentplayer.hash%>&isNotInit=1" onmouseover="tooltip.show(this)"  onmouseout="tooltip.hide(this)" title="Search players with same hash">
		<%ut3x.currentplayer.hash%></a>
	</td>
	<td><%ut3x.currentplayer.isafk%></td>
	<td><%ut3x.currentplayer.isadmin%></td>
	<td><%ut3x.currentplayer.isspec%></td>
	<td>
		<form method="post" action="<%page.fulluri%>">
		<select name="action" id="action<%ut3x.currentplayer.playerid%>">
			<%ut3x.banreasons%>
		</select>
		<input type="hidden" name="hiddenaction" id="hiddenaction<%ut3x.currentplayer.playerid%>"/>
		<input type="hidden" name="playerid" value="<%ut3x.currentplayer.playerid%>"/>
		<button type="submit" onclick="return confirm('Are you sure you want to do this?');">go</button>
	</td>
	</form>
</tr>
