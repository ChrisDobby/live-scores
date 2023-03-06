export const handler = async ({ headers: { authorization } }) => ({ isAuthorized: authorization === process.env.API_KEY });
