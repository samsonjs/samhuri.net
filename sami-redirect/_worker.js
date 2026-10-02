// sami.samhuri.net is a legacy host. Old date-based post URLs map to
// /posts/YYYY/MM/slug on the main site; everything else goes to the same path.
const OLD_POST = /^\/([0-9]{4})\/([0-9]{1,2})\/[0-9]{1,2}\/(.*)$/;

export default {
  fetch(request) {
    const url = new URL(request.url);
    const match = OLD_POST.exec(url.pathname);
    if (match) {
      const [, year, month, rest] = match;
      return Response.redirect(`https://samhuri.net/posts/${year}/${month.padStart(2, "0")}/${rest}`, 301);
    }
    return Response.redirect(`https://samhuri.net${url.pathname}${url.search}`, 301);
  },
};
