<?xml version='1.0' encoding='utf-8'?>
<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>
	<xsl:output omit-xml-declaration="yes" indent="no" />
	<xsl:param name="consecutiveMessage" />
	<xsl:param name="bulkTransform" />
	<xsl:param name="timeFormat" />

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$consecutiveMessage = 'yes'">
				<xsl:apply-templates select="/envelope/message[last()]" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="envelope | message">
		<xsl:variable name="envelopeClasses">
			<xsl:text>message</xsl:text>
			<xsl:if test="message[1]/@highlight = 'yes' or @highlight = 'yes'">
				<xsl:text> message-highlight</xsl:text>
			</xsl:if>
			<xsl:if test="count( message ) &gt; 1">
					<xsl:text> message-consecutive</xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="sender/@self = 'yes' or ../sender/@self = 'yes'">
					<xsl:text> message-outgoing</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> messsage-incoming</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="message[1]/@action = 'yes' or @action = 'yes'">
				<xsl:text> message-action</xsl:text>
			</xsl:if>
			<xsl:if test="message[1]/@type = 'notice' or @type = 'notice'">
				<xsl:text> message-notice</xsl:text>
			</xsl:if>
			<xsl:if test="message[1]/@ignored = 'yes' or @ignored = 'yes' or ../@ignored = 'yes'">
				<xsl:text> message-ignore</xsl:text>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="datetime">
			<xsl:call-template name="iso-datetime">
				<xsl:with-param name="date" select="message[1]/@received | @received" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="timestamp">
			<xsl:call-template name="short-time">
				<xsl:with-param name="date" select="message[1]/@received | @received" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="senderClasses">
			<xsl:text>member</xsl:text>
			<xsl:if test="sender/@self = 'yes' or ../sender/@self = 'yes'">
				<xsl:text> member-self</xsl:text>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="memberLink">
			<xsl:choose>
				<xsl:when test="sender/@identifier or ../sender/@identifier">
					<xsl:text>member:identifier:</xsl:text><xsl:value-of select="sender/@identifier | ../sender/@identifier" />
				</xsl:when>
				<xsl:when test="sender/@nickname or ../sender/@nickname">
					<xsl:text>member:</xsl:text><xsl:value-of select="sender/@nickname | ../sender/@nickname" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>member:</xsl:text><xsl:value-of select="sender | ../sender" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="hostmask" select="sender/@hostmask | ../sender/@hostmask" />

		<article id="{message[1]/@id | @id}" class="{$envelopeClasses} table--row">
			<p class="message--sender table--cell">
				<a href="{$memberLink}" title="{$hostmask}" class="{$senderClasses}"><xsl:value-of select="sender | ../sender" /></a><span class="hidden">: </span>
			</p>
			<p class="message--content table--cell">
				<xsl:if test="message[1]/@action = 'yes' or @action = 'yes'">
					<xsl:text>• </xsl:text>
					<a href="{$memberLink}" title="{$hostmask}" class="action {$senderClasses}">
						<xsl:value-of select="sender | ../sender" />
					</a>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="message[1]">
						<xsl:apply-templates select="message[1]/child::node()" mode="copy" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="child::node()" mode="copy" />
					</xsl:otherwise>
				</xsl:choose>
			</p>
			<time class="message--timestamp table--cell" datetime="{$datetime}"> <xsl:value-of select="$timestamp" /></time>
		</article>

		<xsl:apply-templates select="message[position() &gt; 1]" />
	</xsl:template>

	<xsl:template match="event">
		<xsl:variable name="datetime">
			<xsl:call-template name="iso-datetime">
				<xsl:with-param name="date" select="@occurred" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="timestamp">
			<xsl:call-template name="short-time">
				<xsl:with-param name="date" select="@occurred" />
			</xsl:call-template>
		</xsl:variable>

		<div class="event table--row">
			<p class="event--sender table--cell"></p>
			<p class="event--content table--cell">
				<xsl:apply-templates select="message/child::node()" mode="event" />
				<xsl:if test="string-length( reason )">
					<span class="event--reason">
						<xsl:text> (</xsl:text>
						<xsl:apply-templates select="reason/child::node()" mode="copy" />
						<xsl:text>)</xsl:text>
					</span>
				</xsl:if>
			</p>
			<time class="event--timestamp table--cell" datetime="{$datetime}"> <xsl:value-of select="$timestamp" /></time>
		</div>
	</xsl:template>

	<xsl:template match="a" mode="copy">
		<xsl:variable name="extension" select="substring(@href,string-length(@href) - 3, 4)" />
		<xsl:variable name="extensionLong" select="substring(@href,string-length(@href) - 4, 5)" />
		<xsl:choose>
			<xsl:when test="$extension = '.jpg' or $extension = '.JPG' or $extensionLong = '.jpeg' or $extensionLong = '.JPEG'">
				<a href="{@href}" title="{@href}"><img src="{@href}" alt="Loading Image…" onload="scrollToBottom()" onerror="scrollToBottom()" /></a>
			</xsl:when>
			<xsl:when test="$extension = '.gif' or $extension = '.GIF'">
				<a href="{@href}" title="{@href}"><img src="{@href}" alt="Loading Image…" onload="scrollToBottom()" onerror="scrollToBottom()" /></a>
			</xsl:when>
			<xsl:when test="$extension = '.png' or $extension = '.PNG'">
				<a href="{@href}" title="{@href}"><img src="{@href}" alt="Loading Image…" onload="scrollToBottom()" onerror="scrollToBottom()" /></a>
			</xsl:when>
			<xsl:when test="$extension = '.tif' or $extension = '.TIF' or $extensionLong = '.tiff' or $extensionLong = '.TIFF'">
				<a href="{@href}" title="{@href}"><img src="{@href}" alt="Loading Image…" onload="scrollToBottom()" onerror="scrollToBottom()" /></a>
			</xsl:when>
			<xsl:when test="$extension = '.pdf' or $extension = '.PDF'">
				<a href="{@href}" title="{@href}"><img src="{@href}" alt="Loading Image…" onload="scrollToBottom()" onerror="scrollToBottom()" /></a>
			</xsl:when>
			<xsl:when test="$extension = '.bmp' or $extension = '.BMP'">
				<a href="{@href}" title="{@href}"><img src="{@href}" alt="Loading Image…" onload="scrollToBottom()" onerror="scrollToBottom()" /></a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="current()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="span[contains(@class,'member')]" mode="event">
		<xsl:variable name="nickname" select="current()" />
		<xsl:choose>
			<xsl:when test="../../node()[node() = $nickname]/@hostmask">
				<xsl:variable name="hostmask" select="../../node()[node() = $nickname]/@hostmask" />
				<a href="member:{$nickname}" title="{$hostmask}" class="member"><xsl:copy-of select="@*" /><xsl:apply-templates select="current()/child::node()" mode="copy" /></a>
				<xsl:if test="../../@name = 'memberJoined' or ../../@name = 'memberParted'">
					<span class="hostmask">
						<xsl:text> (</xsl:text>
						<xsl:value-of select="$hostmask" />
						<xsl:text>) </xsl:text>
					</span>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<a href="member:{$nickname}" class="member"><xsl:copy-of select="@*" /><xsl:apply-templates select="current()/child::node()" mode="copy" /></a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="span[contains(@class,'member')]" mode="copy">
		<a href="member:{current()}" class="member"><xsl:copy-of select="@*" /><xsl:apply-templates select="current()/child::node()" mode="copy" /></a>
	</xsl:template>

	<xsl:template match="@*|*" mode="event">
		<xsl:copy><xsl:apply-templates select="@*|node()" mode="event" /></xsl:copy>
	</xsl:template>

	<xsl:template match="@*|*" mode="copy">
		<xsl:copy><xsl:apply-templates select="@*|node()" mode="copy" /></xsl:copy>
	</xsl:template>

	<xsl:template name="short-time">
		<xsl:param name="date" /> <!-- YYYY-MM-DD HH:MM:SS +/-HHMM -->
		<xsl:variable name='hour' select='substring($date, 12, 2)' />
		<xsl:variable name='minute' select='substring($date, 15, 2)' />
		<xsl:choose>
			<xsl:when test="contains($timeFormat,'H')">
				<!-- 24hr format -->
				<xsl:value-of select="concat($hour,':',$minute)" />
			</xsl:when>
			<xsl:otherwise>
				<!-- am/pm format -->
				<xsl:choose>
					<xsl:when test="number($hour) &gt; 12">
						<xsl:value-of select="number($hour) - 12" />
					</xsl:when>
					<xsl:when test="number($hour) = 0">
						<xsl:text>12</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$hour" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="$minute" />
				<xsl:choose>
					<xsl:when test="number($hour) &gt;= 12">
						<xsl:text>p</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>a</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="iso-datetime">
		<xsl:param name="date" /> <!-- YYYY-MM-DD HH:MM:SS +/-HHMM -->
		<xsl:variable name='day' select='substring($date, 1, 10)' />
		<xsl:variable name='time' select='substring($date, 12, 8)' />
		<xsl:variable name='offset' select='substring($date, 21, 5)' />
		<!-- ISO 8601 format -->
		<xsl:value-of select="$day" /><xsl:text>T</xsl:text><xsl:value-of select="$time" /><xsl:value-of select="$offset" />
	</xsl:template>
</xsl:stylesheet>
