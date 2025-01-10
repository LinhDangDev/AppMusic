const authMiddleware = async (req, res, next) => {
  // Gán một user ID mặc định
  req.user = {
    uid: 'default-user',
    role: 'user'
  };
  next();
};

export default authMiddleware;
