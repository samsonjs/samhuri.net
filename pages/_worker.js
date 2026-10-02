// Runs only for the paths in _routes.json; everything else is served as a
// plain static asset without invoking this at all.
const OLD_POST = /^\/posts\/([0-9]{4})\/([0-9]{1,2})\/[0-9]{1,2}\/(.*)$/;
const WEBFINGER = {
  "acct:sjs@samhuri.net": "/.well-known/webfinger-sjs.json",
  "acct:sami@samhuri.net": "/.well-known/webfinger-sami.json",
};

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname === "/.well-known/webfinger") {
      const file = WEBFINGER[url.searchParams.get("resource")];
      if (file) {
        const asset = await env.ASSETS.fetch(new URL(file, url));
        const response = new Response(asset.body, asset);
        response.headers.set("Content-Type", "application/jrd+json");
        response.headers.set("Access-Control-Allow-Origin", "*");
        return response;
      }
      return env.ASSETS.fetch(request);
    }

    const match = OLD_POST.exec(url.pathname);
    if (match) {
      const [, year, month, rest] = match;
      return new Response(null, {
        status: 301,
        headers: { Location: `/posts/${year}/${month.padStart(2, "0")}/${rest}` },
      });
    }

    return env.ASSETS.fetch(request);
  },
};
