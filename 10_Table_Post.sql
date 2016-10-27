USE [SeattleWA_subreddit]
GO

/****** Object:  Table [dbo].[post]    Script Date: 10/25/2016 1:30:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[post](
	[created_utc] [bigint] NULL,
	[created_pacific] datetime NULL,
	[subreddit] [nvarchar](255) NULL,
	[author] [nvarchar](255) NULL,
	[domain] [nvarchar](255) NULL,
	[url] [nvarchar](max) NULL,
	[num_comments] [int] NULL,
	[score] [int] NULL,
	[ups] [int] NULL,
	[downs] [int]  NULL,
	[title] [nvarchar](4000) NULL,
	[selftext] [nvarchar](max) NULL,
	[saved] bit  NULL,
	[id] [nvarchar](255) NULL,
	[from_kind] [nvarchar](255) NULL,
	[gilded] int NULL,
	[from] [nvarchar](255) NULL,
	[stickied] [bit] NULL,
	[retrieved_on] [bigint] NULL,
	[over_18] [bit] NULL,
	[thumbnail] [nvarchar](4000) NULL,
	[subreddit_id] [nvarchar](255) NULL,
	[hide_score] [bit] NULL,
	[link_flair_css_class] [nvarchar](1000) NULL,
	[author_flair_css_class] [nvarchar](1000) NULL,
	[archived] [bit] NULL,
	[is_self] [bit] NULL,
	[from_id] [nvarchar](255) NULL,
	[permalink] [nvarchar](max) NULL,
	[name] [nvarchar](255) NULL,
	[author_flair_text] [nvarchar](1000) NULL,
	[quarantine] [bit] NULL,
	[link_flair_text] [nvarchar](1000) NULL,
	[distinguished] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


