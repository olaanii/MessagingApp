import 'throttled_email_idp_endpoint.dart';

/// Email IdP with ADR-0007 rate limits on login / registration / password reset.
class EmailIdpEndpoint extends ThrottledEmailIdpEndpoint {}
