<tr class="<%evenodd%>" name="ligne" id="<%balancer.numScoreDiff%>">
  <form method="post" action="<%page.fulluri%>">
	<td>
		<!--TO CHANGE -->
		<!--
		<select name="scoreDiff">
			<option value="2-7">Low/High (2->7)</option>
			<option value="2-2">Low (2)</option>
			<option value="3-3">Medium (3)</option>
			<option value="4-5">High (4->5)</option>
			<option value="6-7">Very High (6->7)</option>
		</select>
		-->
		Min:<input type="text" style="text-align: right;" name="minScoreDiff" value="<%balancer.minScoreDiff%>" size="3"/><br>
		Max:<input type="text" style="text-align: right;" name="maxScoreDiff" value="<%balancer.maxScoreDiff%>" size="3" />
	</td>
	<td>
		<!--
		<select name="totalPlayers">
			<option value="1-32">Any (1->32)</option>
			<option value="0-8">Low (1->8)</option>
			<option value="9-16">Medium (9->16)</option>
			<option value="17-24">High (17->24)</option>
			<option value="25-32">Very High (25->32)</option>
		</select>
		-->
		Min:<input type="text" style="text-align: right;" name="minTotalPlayers" value="<%balancer.minTotalPlayers%>" size="3"/><br>
		Max:<input type="text" style="text-align: right;" name="maxTotalPlayers" value="<%balancer.maxTotalPlayers%>" size="3"/>
	</td>
	<td><input type="text" style="text-align: right;" name="numPlayersBoosted" value="<%balancer.numPlayersBoosted%>" size="3"/></td>
	<td>
		<select multiple="true" name="BalanceActionn" id="BalanceAction-<%balancer.numScoreDiff%>" style="height: 100px";>
			<option value="BA_GIVE_FULLHP">Give 199HP</option>
			<option value="BA_GIVE_FULLHPANDARMOR">Give 199HP and Armor</option>
			<option value="BA_GIVE_BOOTS">Give Boots</option>
			<option value="BA_GIVE_BERSERK">Give Berserk(30s)</option>
			<option value="BA_GIVE_UDAMAGE">Give UDamage(30s)</option>
			<option value="BA_GIVE_VH_RAPTOR">Give Raptor</option>
			<option value="BA_GIVE_VH_VIPER">Give Viper</option>
			<option value="BA_GIVE_INVISIBILITY">Give Invisibility(30s)</option>
			<option value="BA_GIVE_WP_DEEMER">Give Deemer</option>
			<option value="BA_GIVE_VH_TANK">Give Tank</option>
			<option value="BA_GIVE_VH_LEVIATHAN">Give Leviathan</option>
			<option value="BA_GIVE_INVULNERABILITY">Give Invulnerability(30s)</option>
			<option value="BA_GIVE_WP_INSTAGIB">Give InstaGib</option>
			<option value="BA_MAKETITAN">Make Titan</option>
			<option value="BA_MAKESUPERTITAN">Make Super-Titan</option>
		</select>
		<input type="hidden" value="<%balancer.balanceactions%>" id="BalanceActions-<%balancer.numScoreDiff%>"/>
	</td>
	<td>
		<input type="hidden" name="numScoreDiff" value="<%balancer.numScoreDiff%>"/>
		<button type="submit" name="action" value="save">Save</button>
		<button type="submit" name="action" value="delete" onclick="return confirm('Are you sure you want to delete?');">Delete</button>
	</td>
  </form>
</tr>
