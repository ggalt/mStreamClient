#ifndef MSTREAMIMAGEPROVIDER_H
#define MSTREAMIMAGEPROVIDER_H

/****************************************************************************
**
** Copyright (C) 2015 Canonical Limited and/or its subsidiary(-ies)
** Contact: https://www.qt.io/licensing/
**
** This file is part of the demonstration applications of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

/****************************************************************************
**
** Modifications made by George Galt under BSD license 2019
**
****************************************************************************/

#include <qqmlextensionplugin.h>

#include <QQmlEngine>
#include <QQuickImageProvider>
#include <QDebug>
#include <QImage>
#include <QThreadPool>
#include <QByteArray>
#include <QString>
#include <QUrl>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QImageReader>

class AsyncImageResponse : public QQuickImageResponse, public QRunnable
{
public:
    AsyncImageResponse(const QString &id, const QSize &requestedSize, QUrl imageURL, QByteArray accessToken );
    QQuickTextureFactory *textureFactory() const override;
    void run() override;

private:
    QUrl m_imageURL;
    QByteArray m_accessToken;
    QSize m_requestedSize;
    QImageReader m_reader;
    QImage m_image;
    QString m_id;
};

class AsyncImageProvider : public QQuickAsyncImageProvider
{
public:
    QQuickImageResponse *requestImageResponse(const QString &id, const QSize &requestedSize) override;

    void setImageServerURL( const QString &imageURL) { m_imageServerURL = imageURL; }
    QString imageServerURL(void) { return m_imageServerURL; }

    void setAccessToken( const QByteArray &token ) { m_accessToken = token; }
    QByteArray accessToken(void) { return m_accessToken; }

private:
    QThreadPool pool;
    QByteArray m_accessToken;
    QString m_imageServerURL;
};


//class ImageProviderExtensionPlugin : public QQmlExtensionPlugin
//{
//    Q_OBJECT
//    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
//public:
//    void registerTypes(const char *uri) override
//    {
//        Q_UNUSED(uri);
//    }

//    void initializeEngine(QQmlEngine *engine, const char *uri) override
//    {
//        Q_UNUSED(uri);
//        engine->addImageProvider("async", new AsyncImageProvider);
//    }

//};

//#include "imageresponseprovider.moc"

#endif // MSTREAMIMAGEPROVIDER_H
