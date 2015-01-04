USE [inDoorAirQuality]
GO

/****** Object:  Table [dbo].[Temperature]    Script Date: 22/10/2014 11:25:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Temperature](
	[Value] [float] NOT NULL,
	[DateTime] [datetime] NOT NULL,
	[ID] [nchar](10) NOT NULL,
 CONSTRAINT [PK_Temperature] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

