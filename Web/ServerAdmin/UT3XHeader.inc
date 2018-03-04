<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>UT3 WebAdmin - <%page.title%></title>
	<link rel="stylesheet" type="text/css" href="/images/ut3.css" title="Unreal Tournament 3" />
	<link rel="stylesheet" type="text/css" href="/images/farbtastic.css" />
	<link rel="stylesheet" type="text/css" href="/images/css/ui-darkness/jquery-ui-1.8.22.custom.css" />
	<link rel="stylesheet" type="text/css" href="/images/ut3x.css" title="ut3x"/>
	<link rel="shortcut icon" href="/images/favicon.ico" type="image/x-icon" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<meta name="generator" content="UT3 WebAdmin v<%build.version%> - <%build.timestamp%>" />
	<script type="text/javascript" src="/images/jquery-3.3.1.min.js"></script>
	<script type="text/javascript" src="/images/jquery-ui.min.js"></script>
	<script type="text/javascript" src="/images/farbtastic.js"></script>
	<script type="text/javascript" src="/images/UT3X.js"></script>
	<script type="text/javascript" src="/images/tooltip.js"></script>
	<script type="text/javascript" src="/images/jquery.tablesorter.js"></script>
	<script type="text/javascript" src="/images/jquery-ui-timepicker-addon.js"></script>
	<%html.headers%>
</head>
<body>
<style>
	.ui-timepicker-div .ui-widget-header { margin-bottom: 8px; }
	.ui-timepicker-div dl { text-align: left; }
	.ui-timepicker-div dl dt { height: 25px; margin-bottom: -25px; }
	.ui-timepicker-div dl dd { margin: 0 10px 10px 65px; }
	.ui-timepicker-div td { font-size: 90%; }
	.ui-tpicker-grid-label { background: none; border: none; margin: 0; padding: 0; }
</style>

<div id="header">
<h1><span>UT3 WebAdmin</span></h1>
<h3 id="pageUri"><%page.uri%></h3>
<h4 id="adminName">Welcome <span class="username"><%admin.name%></span></h4>
<h2 id="pageTitle"><%page.title%></h2>
<p id="pageDescription"><%page.description%></p>
</div>

<div id="messages">
<%messages%>
</div>

<div id="tooltip" style="position:absolute;visibility:hidden;background-color:#FFEEC7; border:1px solid black;padding:0.2em; font-size:0.8em; z-index: 10000;">
</div>