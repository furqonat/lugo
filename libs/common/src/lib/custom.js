import nodemailer from "nodemailer";
const { MAIL_HOST, MAIL_PORT, MAIL_SECURE, MAIL_USER, MAIL_PASS, MAIL_FROM } =
  process.env;

export const sendEmail = async(email, subject, text, html ) => {
  try {
    const transporter = nodemailer.createTransport({
      service: "Gmail",
      host: MAIL_HOST,
      port: MAIL_PORT || 587,
      secure: MAIL_SECURE, // Use `true` for port 465, `false` for all other ports
      auth: {
        user: MAIL_USER,
        pass: MAIL_PASS,
      },
    });
    const info = await transporter.sendMail({
      from: `"LUGO App" <${MAIL_FROM}>`, // sender address
      to: email, // list of receivers
      subject: subject, // Subject line
      text: text, // plain text body
      html: html, // html body
    });
    console.log("Message sent: %s", info.messageId);
    return true;
  } catch (e) {
    console.log(e);
    return false;
  }
}
