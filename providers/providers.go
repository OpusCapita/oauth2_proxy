package providers

import (
	"github.com/OpusCapita/oauth2_proxy/cookie"
	"github.com/OpusCapita/oauth2_proxy/pkg/apis/sessions"
)

// Provider represents an upstream identity provider implementation
type Provider interface {
	Data() *ProviderData
	GetEmailAddress(*sessions.SessionState) (string, error)
	GetUserName(*sessions.SessionState) (string, error)
	Redeem(string, string) (*sessions.SessionState, error)
	ValidateGroup(string) bool
	ValidateSessionState(*sessions.SessionState) bool
	GetLoginURL(redirectURI, finalRedirect string) string
	RefreshSessionIfNeeded(*sessions.SessionState) (bool, error)
	SessionFromCookie(string, *cookie.Cipher) (*sessions.SessionState, error)
	CookieForSession(*sessions.SessionState, *cookie.Cipher) (string, error)
}

// New provides a new Provider based on the configured provider string
func New(provider string, p *ProviderData) Provider {
	switch provider {
	case "linkedin":
		return NewLinkedInProvider(p)
	case "facebook":
		return NewFacebookProvider(p)
	case "github":
		return NewGitHubProvider(p)
	case "azure":
		return NewAzureProvider(p)
	case "gitlab":
		return NewGitLabProvider(p)
	case "oidc":
		return NewOIDCProvider(p)
	case "login.gov":
		return NewLoginGovProvider(p)
	default:
		return NewGoogleProvider(p)
	}
}
