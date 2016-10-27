USE [SeattleWA_subreddit]
GO

/****** Object:  Table [dbo].[comment]    Script Date: 10/25/2016 3:02:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[comment](
	[body] [nvarchar](max) NULL,
	[score_hidden] [bit] NOT NULL,
	[archived] [bit] NOT NULL,
	[name] [nvarchar](50) NULL,
	[author] [nvarchar](500) NULL,
	[author_flair_text] [nvarchar](255) NULL,
	[downs] [int] NULL,
	[created_utc] [bigint] NOT NULL,
	[created_pacific] [datetime] NOT NULL,
	[subreddit_id] [nvarchar](50) NULL,
	[link_id] [nvarchar](50) NULL,
	[parent_id] [nvarchar](50) NULL,
	[score] [int] NULL,
	[retrieved_on] [bigint] NULL,
	[controversiality] [int] NULL,
	[gilded] [int] NOT NULL,
	[id] [nvarchar](50) NULL,
	[subreddit] [nvarchar](500) NULL,
	[ups] [int] NULL,
	[distinguished] [nvarchar](500) NULL,
	[author_flair_css_class] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

