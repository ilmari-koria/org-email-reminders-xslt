<xsl:stylesheet version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:org="https://nwalsh.com/ns/org-to-xml" 
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		exclude-result-prefixes="xs org">
  <!-- this stylesheet is based on org to xml conversion via:
       https://github.com/ndw/org-to-xml -->
  <xsl:output method="html" indent="yes"/>
  <xsl:variable name="today" select="current-date()"/>
  <xsl:param name="type"/>
  <xsl:template match="/">
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
    <html>
      <head>
        <title>TODO Reminder</title>
      </head>
      <body style="font-family: Arial, sans-serif; margin: 20px;">
        <h1 style="color: #333366;"><xsl:value-of select="$type"/></h1>
        <table style="border-collapse: collapse; width: 100%; margin-top: 20px;">
          <tr>
            <th style="width: 33%; border: 1px solid #ddd; padding: 10px; text-align: left; background-color: #f4f4f4;">Title</th>
            <th style="width: 33%; border: 1px solid #ddd; padding: 10px; text-align: left; background-color: #f4f4f4;">Days Left</th>
	    <th style="width: 33%; border: 1px solid #ddd; padding: 10px; text-align: left; background-color: #f4f4f4;">Date</th>
          </tr>
	  <xsl:apply-templates select="//org:headline[@todo-keyword='TODO']/org:deadline">
            <xsl:sort select="xs:date(concat(org:timestamp/@year-start, '-', 
                              format-number(org:timestamp/@month-start, '00'), '-', 
                              format-number(org:timestamp/@day-start, '00')))" 
		      data-type="text" order="ascending"/>
          </xsl:apply-templates>
        </table>
      </body>
    </html>
  </xsl:template>
  <!-- Note these draw from custom keywords by the author -->
  <xsl:template match="org:headline[@todo-keyword='TODO']/org:deadline or
                       org:headline[@todo-keyword='REPEAT']/org:deadline or
                       org:headline[@todo-keyword='NOTES']/org:deadline or
                       org:headline[@todo-keyword='WAITING']/org:deadline">
    <xsl:variable name="month" select="format-number(org:timestamp/@month-start, '00')"/>
    <xsl:variable name="day" select="format-number(org:timestamp/@day-start, '00')"/>
    <xsl:variable name="hour" select="format-number(org:timestamp/@hour-start, '00')"/>
    <xsl:variable name="minute" select="format-number(org:timestamp/@minute-start, '00')"/>
    <xsl:variable name="hour-end" select="format-number(org:timestamp/@hour-end, '00')"/>
    <xsl:variable name="minute-end" select="format-number(org:timestamp/@minute-end, '00')"/>
    <xsl:variable name="deadline-date"
		  select="xs:date(concat(org:timestamp/@year-start, '-', $month, '-', $day))"/>
    <xsl:variable name="days-left" select="days-from-duration($deadline-date - $today)"/>
    <xsl:variable name="full-timestamp">
      <xsl:choose>
	<xsl:when test="org:timestamp/@hour-start and org:timestamp/@minute-start and org:timestamp/@hour-end and org:timestamp/@minute-end">
	  <xsl:variable name="start-time">
            <xsl:value-of select="format-dateTime(xs:dateTime(concat(org:timestamp/@year-start, '-', $month, '-', $day, 'T', $hour, ':', $minute, ':00Z')),'[FNn], [D1o] [MNn] [Y0001], [h01]:[m01] [P]')"/>
	  </xsl:variable>
	  <xsl:variable name="end-time">
            <xsl:value-of select="format-time(xs:time(concat($hour-end, ':', $minute-end, ':00Z')),'[h01]:[m01] [P]')"/>
	  </xsl:variable>
	  <xsl:value-of select="concat($start-time, ' to ', $end-time)"/>
	</xsl:when>
	<xsl:when test="org:timestamp/@hour-start and org:timestamp/@minute-start">
	  <xsl:value-of select="format-dateTime(xs:dateTime(concat(org:timestamp/@year-start, '-', $month, '-', $day, 'T', org:timestamp/@hour-start, ':', org:timestamp/@minute-start, ':00Z')),'[FNn], [D1o] [MNn] [Y0001], [h01]:[m01] [P]')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="format-date(xs:date(concat(org:timestamp/@year-start, '-', $month, '-', $day)), '[FNn], [D1o] [MNn] [Y0001]')"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$days-left lt 0">
      <tr>
	<td style="width: 33%; border: 1px solid #ddd; padding: 10px;">
          <xsl:value-of select="../org:title"/>
	</td>
	<td style="width: 33%; border: 1px solid #ddd; padding: 10px;">
          <span style="color: red; font-weight: bold;">Overdue!</span>
	</td>
	<td style="width: 33%; border: 1px solid #ddd; padding: 10px;">
          <xsl:value-of select="$full-timestamp"/>
	</td>
      </tr>
    </xsl:if>
    <xsl:if test="$days-left ge 0">
      <tr>
	<td style="width: 33%; border: 1px solid #ddd; padding: 10px;">
          <xsl:value-of select="../org:title"/>
	</td>
	<td style="width: 33%; border: 1px solid #ddd; padding: 10px;">
          <xsl:choose>
            <xsl:when test="$days-left eq 0">
	      <span style="color: red; font-weight: bold;">Due Today!</span>
            </xsl:when>
            <xsl:when test="$days-left eq 1">
	      <span style="color: red; font-weight: bold;">1 day left!</span>
            </xsl:when>
            <xsl:otherwise>
	      <xsl:value-of select="$days-left"/> days left
            </xsl:otherwise>
          </xsl:choose>
	</td>
	<td style="width: 33%; border: 1px solid #ddd; padding: 10px;">
          <xsl:value-of select="$full-timestamp"/>
	</td>
      </tr>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
