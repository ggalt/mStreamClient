#ifndef MESSENGER_H
#define MESSENGER_H

#include <QObject>
#include <QDebug>
#include "mstreamimageprovider.h"

class Messenger : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString imageServerURL READ imageServerURL WRITE setImageServerURL NOTIFY imageServerURLChanged)
    Q_PROPERTY(QByteArray accessToken READ accessToken WRITE setAccessToken NOTIFY accessTokenChanged)
public:
    explicit Messenger(QObject *parent = nullptr);
//    void setImageServerURL( const QString &imageURL) { m_imageServerURL = imageURL; m_imageProvider->setImageServerURL(imageURL); qDebug() << imageURL; emit imageServerURLChanged(); }
    void setImageServerURL( const QString &imageURL);
    QString imageServerURL(void) { return m_imageServerURL; }

//    void setAccessToken( const QByteArray &token ) { m_accessToken = token; m_imageProvider->setAccessToken(token); qDebug() << token; emit accessTokenChanged(); }
    void setAccessToken( const QByteArray &token );
    QByteArray accessToken(void) { return m_accessToken; }

    AsyncImageProvider *getImageProvider(void) { return m_imageProvider; }

signals:
    void imageServerURLChanged();
    void accessTokenChanged();

private:
    QByteArray m_accessToken;
    QString m_imageServerURL;
    AsyncImageProvider *m_imageProvider;
};

#endif // MESSENGER_H
